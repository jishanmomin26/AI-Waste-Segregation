import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Supported categories for classification.
const List<String> kSupportedCategories = [
  'Cardboard',
  'Glass',
  'Metal',
  'Paper',
  'Plastic',
  'Trash',
];

/// Known supported classification routes.
const Set<String> kClassifyRoutes = {
  '/classify',
  '/api/classify',
  '/v1/classify',
};

/// Known supported health check routes.
const Set<String> kHealthRoutes = {
  '/',
  '/health',
  '/api/health',
};

/// Prompt instructions given to Gemini.
const String kGeminiSystemInstruction = '''
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

/// Normalizes path by removing duplicate slashes, trailing slashes, and query params.
String normalizeRoutePath(String rawPath) {
  var path = rawPath.trim();
  final queryIndex = path.indexOf('?');
  if (queryIndex != -1) {
    path = path.substring(0, queryIndex);
  }

  // Collapse multiple consecutive slashes: //classify -> /classify
  path = path.replaceAll(RegExp(r'/+'), '/');

  // Remove trailing slash if length > 1: /classify/ -> /classify
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  return path.toLowerCase();
}

/// Loads key-value pairs from a .env file into a Map.
Map<String, String> loadDotEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return {};
  }

  final lines = file.readAsLinesSync();
  final result = <String, String>{};

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eqIndex = line.indexOf('=');
    if (eqIndex > 0) {
      final key = line.substring(0, eqIndex).trim();
      var val = line.substring(eqIndex + 1).trim();
      if ((val.startsWith('"') && val.endsWith('"')) ||
          (val.startsWith("'") && val.endsWith("'"))) {
        val = val.substring(1, val.length - 1);
      }
      result[key] = val;
    }
  }

  return result;
}

void main() async {
  // Load .env from server/.env or current working directory .env
  final envMap = {
    ...loadDotEnv('.env'),
    ...loadDotEnv('server/.env'),
    ...Platform.environment,
  };

  final apiKey = envMap['GEMINI_API_KEY']?.trim() ?? '';
  var model = envMap['GEMINI_MODEL']?.trim() ?? 'gemini-flash-lite-latest';

  // If set to deprecated models, upgrade to active gemini-flash-lite-latest
  if (model == 'gemini-2.5-flash' ||
      model == 'gemini-1.5-flash' ||
      model == 'gemini-2.0-flash') {
    stderr.writeln(
      'NOTE: $model was deprecated by Google API. Using gemini-flash-lite-latest.',
    );
    model = 'gemini-flash-lite-latest';
  }

  final port = int.tryParse(envMap['PORT'] ?? '8080') ?? 8080;
  final host = envMap['HOST']?.trim() ?? '0.0.0.0';

  final server = await HttpServer.bind(host, port);
  server.autoCompress = true;

  stdout.writeln('====================================================');
  stdout.writeln('AI Waste Segregation - Gemini Proxy Server');
  stdout.writeln('====================================================');
  stdout.writeln('Listening on http://$host:$port');
  stdout.writeln('  - Health check:     http://localhost:$port/health');
  stdout.writeln('  - Classify API:     http://localhost:$port/classify');
  stdout.writeln('  - Android emulator: http://10.0.2.2:$port/classify');
  stdout.writeln('Gemini Model: $model');
  if (apiKey.isEmpty) {
    stderr.writeln('WARNING: GEMINI_API_KEY is not set!');
    stderr.writeln(
      'Set GEMINI_API_KEY in your environment or server/.env file.',
    );
  } else {
    stdout.writeln('GEMINI_API_KEY is configured (length: ${apiKey.length}).');
  }
  stdout.writeln('====================================================');

  await for (final request in server) {
    handleServerRequest(request, apiKey: apiKey, model: model);
  }
}

/// Handles incoming HTTP request with route normalization, CORS, and dispatching.
Future<void> handleServerRequest(
  HttpRequest request, {
  required String apiKey,
  required String model,
}) async {
  final rawPath = request.uri.path;
  final normalizedPath = normalizeRoutePath(rawPath);

  final bool isClassify = kClassifyRoutes.contains(normalizedPath);
  final bool isHealth = kHealthRoutes.contains(normalizedPath);
  final bool routeExists = isClassify || isHealth;

  // Apply CORS headers to all responses
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  request.response.headers.set(
    'Access-Control-Allow-Methods',
    'GET, POST, OPTIONS',
  );
  request.response.headers.set(
    'Access-Control-Allow-Headers',
    'Origin, Content-Type, Accept, Authorization, X-Requested-With',
  );
  request.response.headers.set('Access-Control-Max-Age', '86400');

  stdout.writeln(
    '[${DateTime.now().toIso8601String().substring(11, 19)}] '
    '${request.method} $rawPath (route: $normalizedPath, matched: $routeExists)',
  );

  // 1. If route does not exist, return 404 immediately for all methods (including OPTIONS)
  // so preflight does not mask missing routes.
  if (!routeExists) {
    _sendJson(
      request,
      statusCode: HttpStatus.notFound,
      body: {
        'error': 'Route not found: ${request.method} $rawPath',
        'requestedPath': rawPath,
        'normalizedPath': normalizedPath,
        'supportedRoutes': [
          'GET /health',
          'POST /classify',
        ],
      },
    );
    return;
  }

  // 2. Handle CORS preflight OPTIONS for valid routes
  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  try {
    if (request.method == 'GET') {
      if (isHealth) {
        await _handleHealth(request, apiKey: apiKey, model: model);
      } else {
        _sendJson(
          request,
          statusCode: HttpStatus.methodNotAllowed,
          body: {
            'error': 'Method not allowed. Use POST for $rawPath',
          },
        );
      }
    } else if (request.method == 'POST') {
      if (isClassify) {
        await _handleClassify(request, apiKey: apiKey, model: model);
      } else {
        _sendJson(
          request,
          statusCode: HttpStatus.methodNotAllowed,
          body: {
            'error': 'Method not allowed. Use GET for $rawPath',
          },
        );
      }
    } else {
      _sendJson(
        request,
        statusCode: HttpStatus.methodNotAllowed,
        body: {'error': 'Method not allowed: ${request.method} $rawPath'},
      );
    }
  } catch (e, stack) {
    stderr.writeln('Unhandled server error on $rawPath: $e\n$stack');
    _sendJson(
      request,
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Internal server error: $e'},
    );
  }
}

Future<void> _handleHealth(
  HttpRequest request, {
  required String apiKey,
  required String model,
}) async {
  _sendJson(
    request,
    body: {
      'status': 'ok',
      'service': 'ai-waste-segregation-backend',
      'geminiConfigured': apiKey.isNotEmpty,
      'model': model,
      'supportedCategories': kSupportedCategories,
      'routes': ['GET /health', 'POST /classify'],
    },
  );
}

Future<void> _handleClassify(
  HttpRequest request, {
  required String apiKey,
  required String model,
}) async {
  if (apiKey.isEmpty) {
    _sendJson(
      request,
      statusCode: HttpStatus.internalServerError,
      body: {
        'error':
            'GEMINI_API_KEY is not configured on the backend server. '
            'Please set the GEMINI_API_KEY environment variable and restart the server.',
      },
    );
    return;
  }

  final contentType = request.headers.contentType?.mimeType ?? '';

  String base64Image = '';
  String mimeType = 'image/jpeg';

  if (contentType == 'application/json') {
    final rawBody = await utf8.decodeStream(request);
    if (rawBody.trim().isEmpty) {
      _sendJson(
        request,
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Request body is empty.'},
      );
      return;
    }

    final dynamic parsed;
    try {
      parsed = jsonDecode(rawBody);
    } catch (e) {
      _sendJson(
        request,
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid JSON body: $e'},
      );
      return;
    }

    if (parsed is! Map<String, dynamic>) {
      _sendJson(
        request,
        statusCode: HttpStatus.badRequest,
        body: {'error': 'JSON root must be an object with an "image" field.'},
      );
      return;
    }

    base64Image = parsed['image'] as String? ?? '';
    mimeType = parsed['mimeType'] as String? ?? 'image/jpeg';
  } else if (contentType.startsWith('multipart/form-data')) {
    // Basic multipart parser
    final bytes = await _readAllBytes(request);
    final boundary = request.headers.contentType?.parameters['boundary'];
    if (boundary != null && bytes.isNotEmpty) {
      final extracted = _extractMultipartFile(bytes, boundary);
      if (extracted != null) {
        base64Image = base64Encode(extracted.data);
        mimeType = extracted.mimeType;
      }
    }
  } else {
    // Treat raw stream as raw image bytes
    final bytes = await _readAllBytes(request);
    if (bytes.isNotEmpty) {
      base64Image = base64Encode(bytes);
      mimeType = contentType.isNotEmpty ? contentType : 'image/jpeg';
    }
  }

  // Remove any data URL prefix if sent (e.g. data:image/jpeg;base64,...)
  if (base64Image.contains(',')) {
    final commaIndex = base64Image.indexOf(',');
    final prefix = base64Image.substring(0, commaIndex);
    if (prefix.contains('image/png')) {
      mimeType = 'image/png';
    } else if (prefix.contains('image/webp')) {
      mimeType = 'image/webp';
    }
    base64Image = base64Image.substring(commaIndex + 1);
  }

  base64Image = base64Image.trim();

  if (base64Image.isEmpty) {
    _sendJson(
      request,
      statusCode: HttpStatus.badRequest,
      body: {'error': 'No image data provided. Please provide an image.'},
    );
    return;
  }

  // Build the Gemini API request
  final geminiPayload = {
    'contents': [
      {
        'parts': [
          {'text': kGeminiSystemInstruction},
          {
            'inline_data': {'mime_type': mimeType, 'data': base64Image},
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
          'category': {'type': 'STRING', 'enum': kSupportedCategories},
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
            'description': 'Actionable steps for proper recycling or disposal.',
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

  final httpClient = HttpClient();
  try {
    var activeModel = model;
    var geminiResponse = await _executeGeminiCall(
      httpClient: httpClient,
      model: activeModel,
      apiKey: apiKey,
      payload: geminiPayload,
    );

    // If active model returned 404 or 503, automatically try gemini-flash-lite-latest fallback
    if ((geminiResponse.statusCode == HttpStatus.notFound ||
            geminiResponse.statusCode == HttpStatus.serviceUnavailable) &&
        activeModel != 'gemini-flash-lite-latest') {
      stderr.writeln(
        'Model $activeModel returned ${geminiResponse.statusCode} from Gemini. Retrying with gemini-flash-lite-latest fallback...',
      );
      activeModel = 'gemini-flash-lite-latest';
      geminiResponse = await _executeGeminiCall(
        httpClient: httpClient,
        model: activeModel,
        apiKey: apiKey,
        payload: geminiPayload,
      );
    }

    if (geminiResponse.statusCode == HttpStatus.tooManyRequests) {
      _sendJson(
        request,
        statusCode: HttpStatus.tooManyRequests,
        body: {
          'error':
              'Gemini API rate limit reached. Please wait a few seconds and try again.',
          'upstreamStatusCode': HttpStatus.tooManyRequests,
          'details': geminiResponse.body,
        },
      );
      return;
    }

    if (geminiResponse.statusCode != HttpStatus.ok) {
      stderr.writeln(
        'Gemini API error [${geminiResponse.statusCode}]: ${geminiResponse.body}',
      );
      // Map upstream 404 to 502 Bad Gateway so clients know the proxy route was found
      // but upstream Gemini returned an error for the requested model.
      final int responseStatus = geminiResponse.statusCode == 404
          ? HttpStatus.badGateway
          : (geminiResponse.statusCode == 401 ||
                  geminiResponse.statusCode == 403)
              ? geminiResponse.statusCode
              : HttpStatus.badGateway;

      _sendJson(
        request,
        statusCode: responseStatus,
        body: {
          'error':
              'Upstream Gemini API error (${geminiResponse.statusCode}).',
          'model': activeModel,
          'upstreamStatusCode': geminiResponse.statusCode,
          'details': geminiResponse.body,
        },
      );
      return;
    }

    final dynamic parsedGemini = jsonDecode(geminiResponse.body);
    final candidates = parsedGemini['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      _sendJson(
        request,
        statusCode: HttpStatus.badGateway,
        body: {'error': 'No prediction candidates returned from Gemini.'},
      );
      return;
    }

    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      _sendJson(
        request,
        statusCode: HttpStatus.badGateway,
        body: {'error': 'Empty content parts returned from Gemini.'},
      );
      return;
    }

    final text = parts.first['text'] as String? ?? '';
    final dynamic structured = jsonDecode(text);

    if (structured is! Map<String, dynamic>) {
      _sendJson(
        request,
        statusCode: HttpStatus.badGateway,
        body: {'error': 'Gemini structured response is not a JSON object.'},
      );
      return;
    }

    // Validate category is one of supported categories
    final rawCategory = structured['category']?.toString().trim() ?? '';
    final normalizedCategory = _normalizeCategory(rawCategory);

    final identifiable = structured['identifiable'] == true;
    final confidence = (structured['confidence'] as num?)?.toDouble() ?? 0.0;
    final description = structured['description']?.toString() ?? '';
    final rawInstructions = structured['disposalInstructions'];
    final List<String> instructions =
        rawInstructions is List
            ? rawInstructions.map((e) => e.toString()).toList()
            : <String>[];
    final recyclable = structured['recyclable'] == true;

    final sanitizedResult = {
      'identifiable': identifiable,
      'category': normalizedCategory,
      'confidence': confidence.clamp(0.0, 1.0),
      'description': description,
      'disposalInstructions': instructions,
      'recyclable': recyclable,
    };

    _sendJson(request, body: sanitizedResult);
  } finally {
    httpClient.close();
  }
}

class _GeminiCallResult {
  final int statusCode;
  final String body;
  _GeminiCallResult(this.statusCode, this.body);
}

Future<_GeminiCallResult> _executeGeminiCall({
  required HttpClient httpClient,
  required String model,
  required String apiKey,
  required Map<String, dynamic> payload,
}) async {
  final geminiUrl = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
  );

  final geminiRequest = await httpClient.postUrl(geminiUrl);
  geminiRequest.headers.set('Content-Type', 'application/json');
  geminiRequest.headers.set('x-goog-api-key', apiKey);
  geminiRequest.add(utf8.encode(jsonEncode(payload)));

  final geminiResponse = await geminiRequest.close();
  final geminiResponseBody = await utf8.decodeStream(geminiResponse);
  return _GeminiCallResult(geminiResponse.statusCode, geminiResponseBody);
}

String _normalizeCategory(String input) {
  final lower = input.trim().toLowerCase();
  for (final cat in kSupportedCategories) {
    if (cat.toLowerCase() == lower) {
      return cat;
    }
  }
  return 'Trash';
}

Future<List<int>> _readAllBytes(HttpRequest request) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in request) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

class _MultipartData {
  final List<int> data;
  final String mimeType;
  _MultipartData(this.data, this.mimeType);
}

_MultipartData? _extractMultipartFile(List<int> bytes, String boundary) {
  try {
    final delimiter = utf8.encode('--$boundary');
    final headerDelimiter = utf8.encode('\r\n\r\n');

    final headerStart = _indexOfSequence(bytes, delimiter, 0);
    if (headerStart == -1) return null;

    final contentStart =
        _indexOfSequence(bytes, headerDelimiter, headerStart) +
        headerDelimiter.length;
    final nextBoundary = _indexOfSequence(bytes, delimiter, contentStart);
    if (nextBoundary == -1) return null;

    final headerBytes = bytes.sublist(headerStart, contentStart);
    final headerStr = utf8.decode(headerBytes, allowMalformed: true);

    var mimeType = 'image/jpeg';
    if (headerStr.contains('image/png')) {
      mimeType = 'image/png';
    } else if (headerStr.contains('image/webp')) {
      mimeType = 'image/webp';
    }

    final data = bytes.sublist(
      contentStart,
      nextBoundary - 2,
    ); // trim trailing \r\n
    return _MultipartData(data, mimeType);
  } catch (_) {
    return null;
  }
}

int _indexOfSequence(List<int> source, List<int> sequence, int start) {
  for (int i = start; i <= source.length - sequence.length; i++) {
    bool match = true;
    for (int j = 0; j < sequence.length; j++) {
      if (source[i + j] != sequence[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

void _sendJson(
  HttpRequest request, {
  int statusCode = HttpStatus.ok,
  required Map<String, dynamic> body,
}) {
  request.response.statusCode = statusCode;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(body));
  request.response.close();
}
