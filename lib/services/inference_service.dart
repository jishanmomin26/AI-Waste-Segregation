import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../models/inference_result.dart';

/// Exception thrown when image analysis or classification encounters an error.
class InferenceException implements Exception {
  final String message;
  final Object? cause;

  const InferenceException(this.message, [this.cause]);

  @override
  String toString() => 'InferenceException: $message';
}

/// Metadata and disposal instructions for a waste category.
class WasteCategoryDetails {
  final String category;
  final bool recyclable;
  final String description;
  final List<String> disposalInstructions;

  const WasteCategoryDetails({
    required this.category,
    required this.recyclable,
    required this.description,
    required this.disposalInstructions,
  });
}

/// Service that classifies waste items using the Gemini API.
///
/// For security in mobile deployments, requests are routed through a secure
/// backend proxy server that manages the Gemini API key in a server-side
/// environment variable. A direct Gemini connection can also be enabled for
/// local developer workflows via compile-time environment flags.
class InferenceService {
  /// The 6 strictly supported waste classification categories.
  static const List<String> supportedCategories = [
    'Cardboard',
    'Glass',
    'Metal',
    'Paper',
    'Plastic',
    'Trash',
  ];

  /// Default model version for Gemini.
  static const String defaultGeminiModel = 'gemini-flash-lite-latest';

  /// Compile-time define for custom backend URL.
  static const String _envBackendUrl = String.fromEnvironment(
    'CLASSIFIER_BACKEND_URL',
    defaultValue: String.fromEnvironment('BACKEND_URL', defaultValue: ''),
  );

  /// Compile-time define for direct Gemini API key (developer testing only).
  static const String _envGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Compile-time define for direct Gemini model.
  static const String _envGeminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: defaultGeminiModel,
  );

  final http.Client _httpClient;
  final String? _configuredBackendUrl;
  final String? _directApiKey;
  final String _geminiModel;

  /// Creates an [InferenceService] instance.
  ///
  /// An optional [httpClient] can be supplied for unit testing with mocks.
  /// An optional [backendUrl] or [directApiKey] can override defaults.
  InferenceService({
    http.Client? httpClient,
    String? backendUrl,
    String? directApiKey,
    String? geminiModel,
  }) : _httpClient = httpClient ?? http.Client(),
       _configuredBackendUrl = backendUrl,
       _directApiKey = directApiKey,
       _geminiModel =
           geminiModel ??
           (_envGeminiModel.isNotEmpty ? _envGeminiModel : defaultGeminiModel);

  /// Resolves the default backend URL based on platform.
  ///
  /// - Android emulator: uses `http://10.0.2.2:8080`
  /// - Desktop / iOS Simulator / Web: uses `http://localhost:8080`
  String get effectiveBackendUrl {
    final configured = _configuredBackendUrl;
    if (configured != null && configured.trim().isNotEmpty) {
      return configured.trim();
    }

    if (_envBackendUrl.isNotEmpty) {
      return _envBackendUrl.trim();
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  /// Resolves the canonical URI for the waste classification endpoint.
  ///
  /// Automatically trims whitespace, removes trailing slashes, and avoids
  /// duplicate path segments (e.g. `/classify/classify`) if [effectiveBackendUrl]
  /// already ends with `/classify` or `/api/classify`.
  Uri get classifyUri {
    final raw = effectiveBackendUrl.trim();
    var clean = raw;
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    final lower = clean.toLowerCase();
    if (lower.endsWith('/classify') || lower.endsWith('/api/classify')) {
      return Uri.parse(clean);
    }
    return Uri.parse('$clean/classify');
  }

  /// Category descriptions and disposal instructions mapped by canonical label.
  static const Map<String, WasteCategoryDetails> _categoryDetailsMap = {
    'cardboard': WasteCategoryDetails(
      category: 'Cardboard',
      recyclable: true,
      description:
          'This item is cardboard packaging. Corrugated cardboard and paperboard are widely recyclable when clean and dry.',
      disposalInstructions: [
        'Remove any tape, staples, or plastic wrap attached to the box.',
        'Flatten the cardboard completely to save volume in recycling bins.',
        'Keep it dry; discard heavily food-soiled cardboard with general trash.',
        'Place it inside the designated cardboard or paper recycling bin.',
      ],
    ),
    'glass': WasteCategoryDetails(
      category: 'Glass',
      recyclable: true,
      description:
          'This item is glass. Glass bottles and food jars can be recycled indefinitely without degradation in quality.',
      disposalInstructions: [
        'Empty all liquid or food residue completely.',
        'Rinse the container thoroughly with clean water.',
        'Remove metal or plastic caps and lids to recycle them separately.',
        'Place the intact glass container in the designated glass collection bin.',
      ],
    ),
    'metal': WasteCategoryDetails(
      category: 'Metal',
      recyclable: true,
      description:
          'This item is metal. Aluminium cans and tin/steel food containers are infinitely recyclable and highly energy-efficient to process.',
      disposalInstructions: [
        'Empty any remaining beverage or food contents.',
        'Rinse the container with clean water.',
        'Crush aluminium cans if permitted locally to maximize bin space.',
        'Place the clean metal item into the metal recycling container.',
      ],
    ),
    'paper': WasteCategoryDetails(
      category: 'Paper',
      recyclable: true,
      description:
          'This item is paper. Office paper, newspapers, magazines, and paper packaging can be reprocessed into fresh paper goods.',
      disposalInstructions: [
        'Keep paper clean, dry, and free from moisture or grease.',
        'Remove plastic sleeves, bindings, or large metal clips.',
        'Do not recycle paper contaminated with food, oils, or chemicals.',
        'Deposit into the clean paper recycling container.',
      ],
    ),
    'plastic': WasteCategoryDetails(
      category: 'Plastic',
      recyclable: true,
      description:
          'This item is recyclable plastic. Rigid plastic bottles, jugs, and containers can be cleaned and repurposed into new goods.',
      disposalInstructions: [
        'Empty the container completely of all liquids.',
        'Rinse thoroughly to remove residue and prevent contamination.',
        'Keep caps attached or separate according to local guidelines.',
        'Place into the plastic recycling collection bin.',
      ],
    ),
    'trash': WasteCategoryDetails(
      category: 'Trash',
      recyclable: false,
      description:
          'This item is non-recyclable general waste, contaminated packaging, or composite material that belongs in the landfill bin.',
      disposalInstructions: [
        'Check if any detachable parts or packaging components can be recycled.',
        'Bag the waste securely to prevent litter and odor.',
        'Dispose of it in the general non-recyclable waste bin.',
        'Keep separate from recyclable materials and compost.',
      ],
    ),
  };

  /// System instruction for Gemini image classification.
  static const String geminiSystemInstruction = '''
You are an expert waste segregation and recycling AI assistant.
Analyze the provided image and classify the primary waste or discarded object into EXACTLY ONE of the six supported categories:
- Cardboard: Packaging boxes, corrugated cardboard, cardboard egg cartons, heavy paperboard cartons.
- Glass: Glass beverage bottles, food jars, glassware.
- Metal: Aluminum cans, steel/tin food cans, metal lids, clean foil trays, aerosol cans.
- Paper: Office paper, newspapers, magazines, mail, paper bags, unsoiled paper wrapping.
- Plastic: Plastic bottles, jugs, food tubs, plastic containers, rigid packaging plastics.
- Trash: General non-recyclable refuse, broken ceramics, dirty items, composite unrecyclable packaging, heavily food-soiled packaging, or items that must go to landfill.

Strict Guidelines:
1. Identify Primary Waste Item: Focus on the single prominent discarded item in the foreground. Ignore hands, tables, flooring, shadows, and background clutter.
2. Distinguish Material from Color and Background: Carefully distinguish actual material composition from color or reflection (e.g. silver plastic pouch is Plastic not Metal, transparent plastic is Plastic not Glass, metallic beverage can is Metal).
3. Identifiability Check: If the photo is too dark, blurry, does not contain an identifiable waste item, or shows a completely unrelated object/person:
   - Set "identifiable": false
   - Set "category": "Trash"
   - Set "confidence": 0.0
   - Set "recyclable": false
   - Set "description": "Unable to identify a waste item in this image. Please take a clearer photo in good lighting."
   - Set "disposalInstructions": ["Retake a clear photo focused on the waste item."]
4. When Identifiable:
   - Set "identifiable": true
   - Set "category" to exactly one of: ["Cardboard", "Glass", "Metal", "Paper", "Plastic", "Trash"]
   - Set "confidence": Realistic score between 0.0 and 1.0 (e.g. 0.85-0.98 for clear items). Do not fabricate 1.0 unless 100% certain.
   - Set "recyclable": true for standard curbside recyclables (Cardboard, Glass, Metal, Paper, clean Plastic), false for Trash.
   - Set "description": 1-2 concise, clear sentences explaining what the item is and its material.
   - Set "disposalInstructions": 3-4 specific, actionable bullet steps on how to prepare and properly dispose or recycle the item.
''';

  /// Analyzes an image from [imagePath] or in-memory [imageBytes] and returns the classification result.
  Future<InferenceResult> analyzeImage(
    String imagePath, {
    Uint8List? imageBytes,
  }) async {
    final Uint8List rawBytes;

    if (imageBytes != null && imageBytes.isNotEmpty) {
      rawBytes = imageBytes;
    } else {
      if (kIsWeb) {
        throw const InferenceException(
          'Image bytes must be provided when running on Flutter Web.',
        );
      }

      if (imagePath.trim().isEmpty) {
        throw const InferenceException('Image path cannot be empty.');
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        throw InferenceException('Image file not found at: $imagePath');
      }

      try {
        rawBytes = await file.readAsBytes();
      } catch (e) {
        throw InferenceException('Failed to read image file: $e', e);
      }
    }

    if (rawBytes.isEmpty) {
      throw const InferenceException('Selected image file is empty (0 bytes).');
    }

    // 2. Prepare and optimize image bytes for network upload
    final _PreparedImage prepared = _prepareImage(rawBytes, imagePath);

    // 3. Perform classification either via backend proxy (default/secure)
    // or via direct Gemini API (if key is supplied).
    final String activeDirectKey = _directApiKey ?? _envGeminiApiKey;

    if (activeDirectKey.isNotEmpty) {
      return _classifyDirectGemini(prepared: prepared, apiKey: activeDirectKey);
    } else {
      return _classifyViaBackend(prepared: prepared);
    }
  }

  /// Classifies the image via the backend proxy server.
  Future<InferenceResult> _classifyViaBackend({
    required _PreparedImage prepared,
  }) async {
    final Uri requestUri = classifyUri;
    final String baseUrl = effectiveBackendUrl;

    final payload = {
      'image': prepared.base64Data,
      'mimeType': prepared.mimeType,
    };

    final http.Response response;
    try {
      response = await _httpClient
          .post(
            requestUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 40));
    } on SocketException catch (e) {
      throw InferenceException(
        'Unable to connect to waste classification server at $baseUrl. '
        'Please verify that the backend server is running (see server/README.md).',
        e,
      );
    } on http.ClientException catch (e) {
      throw InferenceException(
        'Network error connecting to classification server at $baseUrl: ${e.message}',
        e,
      );
    } on FormatException catch (e) {
      throw InferenceException('Invalid URL format for backend: $baseUrl', e);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw const InferenceException(
          'Classification request timed out. Please check your internet connection.',
        );
      }
      throw InferenceException('Network request failed: $e', e);
    }

    if (response.statusCode == 429) {
      throw const InferenceException(
        'Classification rate limit reached. Please wait a few seconds and try again.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const InferenceException(
        'Classification authorization error. Please check the backend server API key configuration.',
      );
    }

    if (response.statusCode >= 500) {
      String serverErrorMsg = 'Classification server error';
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map && parsed['error'] != null) {
          serverErrorMsg = parsed['error'].toString();
        }
      } catch (_) {}
      throw InferenceException(
        'Server error ($serverErrorMsg). Please try again shortly.',
      );
    }

    if (response.statusCode != 200) {
      String message = 'Server returned status ${response.statusCode}';
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map && parsed['error'] != null) {
          message = parsed['error'].toString();
        }
      } catch (_) {}
      throw InferenceException(message);
    }

    return parseAndValidateJson(response.body);
  }

  /// Classifies the image directly using the Google Generative Language API.
  Future<InferenceResult> _classifyDirectGemini({
    required _PreparedImage prepared,
    required String apiKey,
  }) async {
    final geminiUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent',
    );

    final geminiPayload = {
      'contents': [
        {
          'parts': [
            {'text': geminiSystemInstruction},
            {
              'inline_data': {
                'mime_type': prepared.mimeType,
                'data': prepared.base64Data,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'response_mime_type': 'application/json',
        'response_schema': {
          'type': 'OBJECT',
          'properties': {
            'identifiable': {
              'type': 'BOOLEAN',
              'description':
                  'True if an identifiable waste item is present; false if blurry or no waste found.',
            },
            'category': {'type': 'STRING', 'enum': supportedCategories},
            'confidence': {
              'type': 'NUMBER',
              'description': 'Confidence score between 0.0 and 1.0.',
            },
            'description': {
              'type': 'STRING',
              'description':
                  '1-2 sentence description of the item and its material.',
            },
            'disposalInstructions': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description':
                  'Actionable steps for proper recycling or disposal.',
            },
            'recyclable': {
              'type': 'BOOLEAN',
              'description':
                  'Whether the item is recyclable in municipal collection.',
            },
          },
          'required': [
            'identifiable',
            'category',
            'confidence',
            'description',
            'disposalInstructions',
            'recyclable',
          ],
        },
        'temperature': 0.1,
      },
    };

    final http.Response response;
    try {
      response = await _httpClient
          .post(
            geminiUrl,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(geminiPayload),
          )
          .timeout(const Duration(seconds: 40));
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw const InferenceException(
          'Gemini API request timed out. Please check your internet connection.',
        );
      }
      throw InferenceException('Failed to communicate with Gemini API: $e', e);
    }

    if (response.statusCode == 429) {
      throw const InferenceException(
        'Gemini API rate limit reached. Please wait a few seconds and try again.',
      );
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      throw const InferenceException(
        'Gemini API key is invalid or unauthorized. Please verify your API key.',
      );
    }

    if (response.statusCode != 200) {
      throw InferenceException(
        'Gemini API returned an error (${response.statusCode}): ${response.body}',
      );
    }

    final dynamic parsed;
    try {
      parsed = jsonDecode(response.body);
    } catch (e) {
      throw InferenceException(
        'Malformed JSON response from Gemini API: $e',
        e,
      );
    }

    final candidates = parsed is Map ? parsed['candidates'] as List? : null;
    if (candidates == null || candidates.isEmpty) {
      throw const InferenceException(
        'No prediction candidates returned from Gemini API.',
      );
    }

    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw const InferenceException('Empty response parts from Gemini API.');
    }

    final text = parts.first['text'] as String? ?? '';
    return parseAndValidateJson(text);
  }

  /// Parses and validates a JSON string into an [InferenceResult].
  static InferenceResult parseAndValidateJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw const InferenceException('Received empty response body.');
    }

    final dynamic parsed;
    try {
      parsed = jsonDecode(jsonString);
    } catch (e) {
      throw InferenceException(
        'Failed to parse JSON classification response: $e',
        e,
      );
    }

    if (parsed is! Map<String, dynamic>) {
      throw const InferenceException(
        'Classification response must be a JSON object.',
      );
    }

    return validateClassificationMap(parsed);
  }

  /// Validates a parsed map and returns an [InferenceResult].
  static InferenceResult validateClassificationMap(Map<String, dynamic> data) {
    // 1. Identifiability check
    final bool isIdentifiable = data['identifiable'] != false;
    final double rawConfidence =
        (data['confidence'] as num?)?.toDouble() ?? 0.0;

    if (!isIdentifiable || rawConfidence < 0.15) {
      throw const InferenceException(
        'The image is unclear or does not contain an identifiable waste item. '
        'Please take a clearer photo in good lighting.',
      );
    }

    // 2. Validate category
    final dynamic rawCategory = data['category'];
    if (rawCategory == null || rawCategory.toString().trim().isEmpty) {
      throw const InferenceException(
        'Classification response is missing the category field.',
      );
    }

    final String normalizedCategory = normalizeCategory(rawCategory.toString());

    // 3. Validate confidence score
    final double confidence = rawConfidence.clamp(0.0, 1.0);

    // 4. Validate or fallback description
    final fallbackDetails = getCategoryDetails(normalizedCategory);
    final String rawDescription = data['description']?.toString().trim() ?? '';
    final String description =
        rawDescription.isNotEmpty
            ? rawDescription
            : fallbackDetails.description;

    // 5. Validate or fallback disposal instructions
    final dynamic rawInstructions = data['disposalInstructions'];
    final List<String> disposalInstructions;
    if (rawInstructions is List && rawInstructions.isNotEmpty) {
      disposalInstructions =
          rawInstructions
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList();
    } else {
      disposalInstructions = fallbackDetails.disposalInstructions;
    }

    // 6. Validate recyclable flag
    final bool recyclable =
        data['recyclable'] is bool
            ? data['recyclable'] as bool
            : fallbackDetails.recyclable;

    return InferenceResult(
      category: normalizedCategory,
      confidence: confidence,
      description: description,
      disposalInstructions: disposalInstructions,
      recyclable: recyclable,
    );
  }

  /// Normalizes category string to match exact supported title-case categories.
  static String normalizeCategory(String input) {
    final trimmed = input.trim().toLowerCase();
    for (final category in supportedCategories) {
      if (category.toLowerCase() == trimmed) {
        return category;
      }
    }

    throw InferenceException(
      'Invalid waste category "$input". Allowed categories are: '
      '${supportedCategories.join(", ")}.',
    );
  }

  /// Maps a label string to its corresponding category metadata.
  static WasteCategoryDetails getCategoryDetails(String label) {
    final key = label.trim().toLowerCase();
    if (_categoryDetailsMap.containsKey(key)) {
      return _categoryDetailsMap[key]!;
    }

    final capitalized =
        label.isNotEmpty
            ? '${label[0].toUpperCase()}${label.substring(1)}'
            : 'Unknown Waste';

    return WasteCategoryDetails(
      category: capitalized,
      recyclable: false,
      description: 'Identified as $capitalized item.',
      disposalInstructions: const [
        'Inspect the material to verify if parts can be recycled.',
        'Dispose of according to local municipal guidelines.',
        'Do not mix with hazardous or electronic waste.',
      ],
    );
  }

  /// Prepares and optimizes the image file bytes for network transmission.
  _PreparedImage _prepareImage(Uint8List bytes, String filePath) {
    String mimeType = 'image/jpeg';
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (lowerPath.endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    // Check magic bytes
    if (bytes.length >= 8) {
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        mimeType = 'image/png';
      } else if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        mimeType = 'image/webp';
      } else if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        mimeType = 'image/jpeg';
      }
    }

    // If file is larger than 1.5MB, downscale to max 1024x1024 JPEG to optimize
    // upload speed, network payload, and API token usage.
    if (bytes.length > 1500 * 1024) {
      try {
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final int maxDim = 1024;
          img.Image resized = decoded;
          if (decoded.width > maxDim || decoded.height > maxDim) {
            if (decoded.width >= decoded.height) {
              resized = img.copyResize(decoded, width: maxDim);
            } else {
              resized = img.copyResize(decoded, height: maxDim);
            }
          }
          final compressed = img.encodeJpg(resized, quality: 85);
          return _PreparedImage(
            base64Data: base64Encode(compressed),
            mimeType: 'image/jpeg',
          );
        }
      } catch (_) {
        // Fallback to sending original bytes if decode fails
      }
    }

    return _PreparedImage(base64Data: base64Encode(bytes), mimeType: mimeType);
  }

  /// Disposes of any resources held by this service.
  void dispose() {
    _httpClient.close();
  }
}

class _PreparedImage {
  final String base64Data;
  final String mimeType;

  const _PreparedImage({required this.base64Data, required this.mimeType});
}
