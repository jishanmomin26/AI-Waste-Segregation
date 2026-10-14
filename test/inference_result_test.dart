import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recycle_app/models/inference_result.dart';
import 'package:recycle_app/services/inference_service.dart';

void main() {
  group('InferenceResult Model', () {
    test('constructs correctly with valid fields', () {
      const result = InferenceResult(
        category: 'Plastic',
        confidence: 0.942,
        description: 'Recyclable plastic container.',
        disposalInstructions: [
          'Empty container.',
          'Rinse with water.',
          'Place in blue bin.',
        ],
        recyclable: true,
      );

      expect(result.category, 'Plastic');
      expect((result.confidence - 0.942).abs() < 1e-6, isTrue);
      expect(result.confidencePercentage, '94%');
      expect(result.recyclable, isTrue);
      expect(result.disposalInstructions.length, 3);
    });

    test('formats edge case confidence percentages correctly', () {
      const zero = InferenceResult(
        category: 'Trash',
        confidence: 0.0,
        description: 'Non-recyclable item.',
        disposalInstructions: [],
        recyclable: false,
      );
      expect(zero.confidencePercentage, '0%');

      const full = InferenceResult(
        category: 'Metal',
        confidence: 1.0,
        description: 'Aluminium beverage can.',
        disposalInstructions: [],
        recyclable: true,
      );
      expect(full.confidencePercentage, '100%');
    });
  });

  group('Category Validation & Normalization', () {
    test('accepts all 6 supported categories in various casings', () {
      for (final expected in InferenceService.supportedCategories) {
        expect(InferenceService.normalizeCategory(expected), expected);
        expect(
          InferenceService.normalizeCategory(expected.toLowerCase()),
          expected,
        );
        expect(
          InferenceService.normalizeCategory(expected.toUpperCase()),
          expected,
        );
      }
    });

    test('rejects unsupported categories with InferenceException', () {
      const unsupported = [
        'organic',
        'e-waste',
        'wood',
        'battery',
        'food',
        'unknown',
      ];
      for (final cat in unsupported) {
        expect(
          () => InferenceService.normalizeCategory(cat),
          throwsA(
            isA<InferenceException>().having(
              (e) => e.message,
              'message',
              contains('Invalid waste category'),
            ),
          ),
        );
      }
    });

    test('rejects empty or whitespace category', () {
      expect(
        () => InferenceService.normalizeCategory('   '),
        throwsA(isA<InferenceException>()),
      );
    });
  });

  group('JSON Parsing & Validation', () {
    test('parses complete valid JSON response', () {
      final json = jsonEncode({
        'identifiable': true,
        'category': 'Metal',
        'confidence': 0.965,
        'description': 'Clean aluminium soda can.',
        'disposalInstructions': [
          'Rinse can.',
          'Crush to save space.',
          'Place in metal bin.',
        ],
        'recyclable': true,
      });

      final result = InferenceService.parseAndValidateJson(json);
      expect(result.category, 'Metal');
      expect((result.confidence - 0.965).abs() < 1e-4, isTrue);
      expect(result.confidencePercentage, '97%');
      expect(result.description, 'Clean aluminium soda can.');
      expect(result.disposalInstructions.length, 3);
      expect(result.recyclable, isTrue);
    });

    test('rejects unidentifiable image flag', () {
      final json = jsonEncode({
        'identifiable': false,
        'category': 'Trash',
        'confidence': 0.0,
        'description': 'No waste item found.',
        'disposalInstructions': [],
        'recyclable': false,
      });

      expect(
        () => InferenceService.parseAndValidateJson(json),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains(
              'The image is unclear or does not contain an identifiable waste item',
            ),
          ),
        ),
      );
    });

    test('rejects extremely low confidence prediction (< 0.15)', () {
      final json = jsonEncode({
        'identifiable': true,
        'category': 'Plastic',
        'confidence': 0.08,
        'description': 'Unclear blurry shape.',
        'disposalInstructions': [],
        'recyclable': true,
      });

      expect(
        () => InferenceService.parseAndValidateJson(json),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains(
              'The image is unclear or does not contain an identifiable waste item',
            ),
          ),
        ),
      );
    });

    test(
      'falls back to default category details if description or instructions are empty',
      () {
        final json = jsonEncode({
          'identifiable': true,
          'category': 'Cardboard',
          'confidence': 0.91,
          'description': '',
          'disposalInstructions': [],
          'recyclable': true,
        });

        final result = InferenceService.parseAndValidateJson(json);
        expect(result.category, 'Cardboard');
        expect(result.description.isNotEmpty, isTrue);
        expect(result.disposalInstructions.isNotEmpty, isTrue);
      },
    );

    test('handles malformed JSON syntax gracefully', () {
      expect(
        () => InferenceService.parseAndValidateJson('{invalid-json-body}'),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains('Failed to parse JSON classification response'),
          ),
        ),
      );
    });

    test('handles non-object JSON gracefully', () {
      expect(
        () => InferenceService.parseAndValidateJson('["not", "an", "object"]'),
        throwsA(isA<InferenceException>()),
      );
    });
  });

  group('Labels File Verification', () {
    test('labels/labels.txt exists and contains all 6 classes', () {
      final labelsFile = File('labels/labels.txt');
      expect(labelsFile.existsSync(), isTrue);

      final labels =
          labelsFile
              .readAsStringSync()
              .split(RegExp(r'\r?\n'))
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList();

      expect(labels.length, 6);
      expect(labels, [
        'cardboard',
        'glass',
        'metal',
        'paper',
        'plastic',
        'trash',
      ]);
    });
  });

  group('InferenceService with Mocked Backend Responses', () {
    late Directory tempDir;
    late File testImageFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('inference_test_');
      testImageFile = File('${tempDir.path}/test_item.jpg');
      // Create a valid 1x1 JPEG byte sequence
      testImageFile.writeAsBytesSync([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        0x00,
        0x10,
        0x4A,
        0x46,
        0x49,
        0x46,
        0x00,
        0x01,
        0x01,
        0x01,
        0x00,
        0x48,
        0x00,
        0x48,
        0x00,
        0x00,
        0xFF,
        0xDB,
        0x00,
        0x43,
        0x00,
        0x08,
        0x06,
        0x06,
        0x07,
        0x06,
        0x05,
        0x08,
        0xFF,
        0xD9,
      ]);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('successfully classifies waste via backend mock client', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/classify');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body.containsKey('image'), isTrue);
        expect(body['mimeType'], 'image/jpeg');

        return http.Response(
          jsonEncode({
            'identifiable': true,
            'category': 'Glass',
            'confidence': 0.95,
            'description': 'A transparent glass jar.',
            'disposalInstructions': [
              'Rinse food residues.',
              'Remove metal lid.',
              'Place in glass recycling bin.',
            ],
            'recyclable': true,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = InferenceService(
        httpClient: mockClient,
        backendUrl: 'http://test-server:8080',
      );

      final result = await service.analyzeImage(testImageFile.path);

      expect(result.category, 'Glass');
      expect((result.confidence - 0.95).abs() < 1e-4, isTrue);
      expect(result.confidencePercentage, '95%');
      expect(result.recyclable, isTrue);
      expect(result.description, 'A transparent glass jar.');
      expect(result.disposalInstructions.length, 3);
    });

    test(
      'successfully classifies waste using in-memory imageBytes directly (web flow)',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/classify');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body.containsKey('image'), isTrue);
          expect(body['mimeType'], 'image/jpeg');

          return http.Response(
            jsonEncode({
              'identifiable': true,
              'category': 'Plastic',
              'confidence': 0.94,
              'description': 'A plastic bottle.',
              'disposalInstructions': ['Empty and rinse.'],
              'recyclable': true,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final service = InferenceService(
          httpClient: mockClient,
          backendUrl: 'http://test-server:8080',
        );

        final sampleBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);
        final result = await service.analyzeImage(
          'dummy_web_path.jpg',
          imageBytes: sampleBytes,
        );

        expect(result.category, 'Plastic');
        expect((result.confidence - 0.94).abs() < 1e-4, isTrue);
        expect(result.confidencePercentage, '94%');
        expect(result.recyclable, isTrue);
      },
    );

    test('handles HTTP 429 Rate Limit error gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Too many requests'}),
          429,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = InferenceService(
        httpClient: mockClient,
        backendUrl: 'http://test-server:8080',
      );

      expect(
        () => service.analyzeImage(testImageFile.path),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains('rate limit reached'),
          ),
        ),
      );
    });

    test('handles HTTP 500 Server Error gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': 'GEMINI_API_KEY is not configured on the backend server.',
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = InferenceService(
        httpClient: mockClient,
        backendUrl: 'http://test-server:8080',
      );

      expect(
        () => service.analyzeImage(testImageFile.path),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains('Server error'),
          ),
        ),
      );
    });

    test('handles non-existent image path', () async {
      final service = InferenceService(
        httpClient: MockClient((_) async => http.Response('', 200)),
        backendUrl: 'http://test-server:8080',
      );

      expect(
        () => service.analyzeImage('non_existent_file.jpg'),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains('Image file not found'),
          ),
        ),
      );
    });

    test('handles empty image path', () async {
      final service = InferenceService(
        httpClient: MockClient((_) async => http.Response('', 200)),
        backendUrl: 'http://test-server:8080',
      );

      expect(
        () => service.analyzeImage(''),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains('Image path cannot be empty'),
          ),
        ),
      );
    });
  });

  group('InferenceService Direct Gemini Mocked Mode', () {
    late Directory tempDir;
    late File testImageFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('inference_direct_test_');
      testImageFile = File('${tempDir.path}/test_item.jpg');
      testImageFile.writeAsBytesSync([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        0x00,
        0x10,
        0x4A,
        0x46,
        0x49,
        0x46,
        0x00,
        0x01,
        0x01,
        0x01,
        0x00,
        0x48,
        0x00,
        0x48,
        0x00,
        0x00,
        0xFF,
        0xD9,
      ]);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('classifies directly using Gemini API response structure', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          contains('generativelanguage.googleapis.com'),
        );
        expect(request.headers['x-goog-api-key'], 'test-api-key');

        final geminiStructuredOutput = jsonEncode({
          'identifiable': true,
          'category': 'Cardboard',
          'confidence': 0.98,
          'description': 'A corrugated shipping cardboard box.',
          'disposalInstructions': [
            'Remove packing tape.',
            'Flatten the box.',
            'Keep it clean and dry.',
            'Place in paper recycling.',
          ],
          'recyclable': true,
        });

        final geminiApiResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': geminiStructuredOutput},
                ],
              },
            },
          ],
        };

        return http.Response(
          jsonEncode(geminiApiResponse),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = InferenceService(
        httpClient: mockClient,
        directApiKey: 'test-api-key',
      );

      final result = await service.analyzeImage(testImageFile.path);

      expect(result.category, 'Cardboard');
      expect((result.confidence - 0.98).abs() < 1e-4, isTrue);
      expect(result.recyclable, isTrue);
      expect(result.disposalInstructions.length, 4);
    });

    test('handles Gemini 403 Invalid API key error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'code': 403, 'message': 'API key not valid.'},
          }),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = InferenceService(
        httpClient: mockClient,
        directApiKey: 'bad-key',
      );

      expect(
        () => service.analyzeImage(testImageFile.path),
        throwsA(
          isA<InferenceException>().having(
            (e) => e.message,
            'message',
            contains('API key is invalid or unauthorized'),
          ),
        ),
      );
    });
  });

  group('Backend URL and Endpoint Resolution', () {
    test('resolves default effectiveBackendUrl', () {
      final service = InferenceService();
      expect(
        service.effectiveBackendUrl == 'http://localhost:8080' ||
            service.effectiveBackendUrl == 'http://10.0.2.2:8080',
        isTrue,
      );
    });

    test('resolves classifyUri without trailing slash', () {
      final service = InferenceService(backendUrl: 'http://localhost:8080');
      expect(service.classifyUri.toString(), 'http://localhost:8080/classify');
    });

    test('resolves classifyUri with trailing slash', () {
      final service = InferenceService(backendUrl: 'http://localhost:8080/');
      expect(service.classifyUri.toString(), 'http://localhost:8080/classify');
    });

    test('avoids duplicate /classify when already specified', () {
      final service = InferenceService(backendUrl: 'http://localhost:8080/classify');
      expect(service.classifyUri.toString(), 'http://localhost:8080/classify');
    });

    test('avoids duplicate /classify when already specified with trailing slash', () {
      final service = InferenceService(backendUrl: 'http://localhost:8080/classify/');
      expect(service.classifyUri.toString(), 'http://localhost:8080/classify');
    });

    test('preserves /api/classify endpoint path', () {
      final service = InferenceService(backendUrl: 'https://proxy.example.com/api/classify');
      expect(service.classifyUri.toString(), 'https://proxy.example.com/api/classify');
    });
  });
}
