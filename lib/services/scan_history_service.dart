import 'package:flutter/foundation.dart';

import '../data/dummy_scans.dart';
import '../models/scan_history_model.dart';

class ScanHistoryService extends ChangeNotifier {
  ScanHistoryService._internal()
    : _scans = List<ScanHistoryModel>.from(DummyScans.scans);

  static final ScanHistoryService instance = ScanHistoryService._internal();

  final List<ScanHistoryModel> _scans;

  List<ScanHistoryModel> get scans =>
      List<ScanHistoryModel>.unmodifiable(_scans);

  void addScan(ScanHistoryModel scan) {
    _scans.insert(0, scan);
    notifyListeners();
  }

  void removeScan(String id) {
    _scans.removeWhere((scan) => scan.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _scans.clear();
    notifyListeners();
  }
}
