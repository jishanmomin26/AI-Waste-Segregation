import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../server/bin/server.dart';

void main() {
  group('Route Path Normalization', () {
    test('normalizes standard classify and health routes', () {
      expect(normalizeRoutePath('/classify'), '/classify');
      expect(normalizeRoutePath('/classify/'), '/classify');
      expect(normalizeRoutePath('//classify'), '/classify');
      expect(normalizeRoutePath('///classify//'), '/classify');
      expect(normalizeRoutePath('/api/classify'), '/api/classify');
      expect(normalizeRoutePath('/api/classify/'), '/api/classify');
      expect(normalizeRoutePath('/health'), '/health');
      expect(normalizeRoutePath('/health/'), '/health');
      expect(normalizeRoutePath('/'), '/');
    });

    test('strips query parameters from route paths', () {
      expect(normalizeRoutePath('/classify?foo=bar&test=1'), '/classify');
      expect(normalizeRoutePath('/health?check=true'), '/health');
    });

    test('lowercases route paths', () {
      expect(normalizeRoutePath('/Classify'), '/classify');
      expect(normalizeRoutePath('/HEALTH'), '/health');
    });

    test('identifies recognized routes accurately', () {
      expect(kClassifyRoutes.contains(normalizeRoutePath('/classify')), isTrue);
      expect(kClassifyRoutes.contains(normalizeRoutePath('/classify/')), isTrue);
      expect(kClassifyRoutes.contains(normalizeRoutePath('//classify')), isTrue);
      expect(kClassifyRoutes.contains(normalizeRoutePath('/api/classify')), isTrue);
      expect(kClassifyRoutes.contains(normalizeRoutePath('/v1/classify')), isTrue);

      expect(kHealthRoutes.contains(normalizeRoutePath('/health')), isTrue);
      expect(kHealthRoutes.contains(normalizeRoutePath('/health/')), isTrue);
      expect(kHealthRoutes.contains(normalizeRoutePath('/')), isTrue);
      expect(kHealthRoutes.contains(normalizeRoutePath('/api/health')), isTrue);

      expect(kClassifyRoutes.contains(normalizeRoutePath('/not-a-route')), isFalse);
      expect(kHealthRoutes.contains(normalizeRoutePath('/not-a-route')), isFalse);
    });
  });

  group('Server Route Dispatch and CORS Handling', () {
    late HttpServer server;
    late Uri serverUri;
    late http.Client client;

    setUp(() async {
      server = await HttpServer.bind('127.0.0.1', 0);
      serverUri = Uri.parse('http://${server.address.address}:${server.port}');
      client = http.Client();

      server.listen((HttpRequest request) {
        handleServerRequest(
          request,
          apiKey: 'test-dummy-api-key',
          model: 'gemini-3.1-flash-lite',
        );
      });
    });

    tearDown(() async {
      client.close();
      await server.close(force: true);
    });

    test('OPTIONS /classify returns 204 with full CORS headers', () async {
      final request = http.Request('OPTIONS', serverUri.replace(path: '/classify'));
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      expect(response.statusCode, 204);
      expect(response.headers['access-control-allow-origin'], '*');
      expect(response.headers['access-control-allow-methods'], contains('POST'));
      expect(response.headers['access-control-allow-headers'], contains('Content-Type'));
    });

    test('OPTIONS /classify/ (with trailing slash) also returns 204 with CORS', () async {
      final request = http.Request('OPTIONS', serverUri.replace(path: '/classify/'));
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      expect(response.statusCode, 204);
      expect(response.headers['access-control-allow-origin'], '*');
    });

    test('OPTIONS /api/classify returns 204 with CORS', () async {
      final request = http.Request('OPTIONS', serverUri.replace(path: '/api/classify'));
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      expect(response.statusCode, 204);
      expect(response.headers['access-control-allow-origin'], '*');
    });

    test('OPTIONS on unknown route returns 404 and does NOT mask missing route', () async {
      final request = http.Request('OPTIONS', serverUri.replace(path: '/non_existent_route'));
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      expect(response.statusCode, 404);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['error'], contains('Route not found'));
    });

    test('GET /health returns 200 with service configuration', () async {
      final response = await client.get(serverUri.replace(path: '/health'));
      expect(response.statusCode, 200);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['status'], 'ok');
      expect(body['service'], 'ai-waste-segregation-backend');
      expect(body['geminiConfigured'], isTrue);
      expect(body['model'], 'gemini-3.1-flash-lite');
      expect(body['supportedCategories'], hasLength(6));
    });

    test('GET /health/ with trailing slash returns 200', () async {
      final response = await client.get(serverUri.replace(path: '/health/'));
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['status'], 'ok');
    });

    test('GET /classify returns 405 Method Not Allowed', () async {
      final response = await client.get(serverUri.replace(path: '/classify'));
      expect(response.statusCode, 405);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['error'], contains('Method not allowed'));
    });

    test('POST /unknown returns 404 Not Found', () async {
      final response = await client.post(
        serverUri.replace(path: '/unknown'),
        body: jsonEncode({'image': 'abc'}),
        headers: {'Content-Type': 'application/json'},
      );
      expect(response.statusCode, 404);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['error'], contains('Route not found'));
    });

    test('POST /classify dispatches to classify handler (returns 400 when body empty)', () async {
      final response = await client.post(
        serverUri.replace(path: '/classify'),
        body: '',
        headers: {'Content-Type': 'application/json'},
      );
      expect(response.statusCode, 400);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['error'], contains('Request body is empty'));
    });

    test('POST /classify/ (with trailing slash) dispatches to classify handler', () async {
      final response = await client.post(
        serverUri.replace(path: '/classify/'),
        body: jsonEncode({'image': ''}),
        headers: {'Content-Type': 'application/json'},
      );
      expect(response.statusCode, 400);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['error'], contains('No image data provided'));
    });
  });
}
