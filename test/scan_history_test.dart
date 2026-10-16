import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recycle_app/models/scan_history_model.dart';
import 'package:recycle_app/services/auth_service.dart';
import 'package:recycle_app/services/scan_history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ScanHistoryService Tests', () {
    test('Initializes with default scans when storage is empty', () async {
      final service = ScanHistoryService.instance;
      await service.init();

      expect(service.scans, isNotEmpty);
      expect(service.totalScans, service.scans.length);
    });

    test('Adding scan increases total count and syncs with AuthService', () async {
      final auth = AuthService.instance;
      await auth.init();
      final initialEcoPoints = auth.currentUser.ecoPoints;

      final service = ScanHistoryService.instance;
      await service.init();
      final initialCount = service.scans.length;

      final newScan = ScanHistoryModel(
        id: 'test_scan_100',
        wasteName: 'Plastic Bottle',
        category: 'Plastic',
        confidence: 0.95,
        date: '16 October 2026',
        time: '12:00 PM',
        recyclable: true,
        description: 'Test recyclable plastic bottle',
      );

      service.addScan(newScan);

      expect(service.scans.length, initialCount + 1);
      expect(service.scans.first.id, 'test_scan_100');
      // Verify AuthService eco points increased
      expect(auth.currentUser.ecoPoints, initialEcoPoints + 20);
    });

    test('ScanHistoryModel JSON serialization and deserialization', () {
      final scan = ScanHistoryModel(
        id: 'json_scan_1',
        wasteName: 'Cardboard Box',
        category: 'Paper',
        confidence: 0.88,
        date: '15 October 2026',
        time: '03:15 PM',
        recyclable: true,
        description: 'Recyclable packaging box',
      );

      final json = scan.toJson();
      final restored = ScanHistoryModel.fromJson(json);

      expect(restored.id, scan.id);
      expect(restored.wasteName, scan.wasteName);
      expect(restored.category, scan.category);
      expect(restored.confidence, scan.confidence);
      expect(restored.date, scan.date);
      expect(restored.time, scan.time);
      expect(restored.recyclable, scan.recyclable);
      expect(restored.description, scan.description);
    });
  });
}
