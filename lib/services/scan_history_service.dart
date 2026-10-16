import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_scans.dart';
import '../models/scan_history_model.dart';
import 'auth_service.dart';

class ScanHistoryService extends ChangeNotifier {
  ScanHistoryService._internal()
      : _scans = List<ScanHistoryModel>.from(DummyScans.scans);

  static final ScanHistoryService instance = ScanHistoryService._internal();

  static const String _keyPlatformScans = 'saved_platform_scan_records';
  static const String _userHistoryKeyPrefix = 'saved_scan_history_';

  final List<ScanHistoryModel> _scans;
  String? _currentUserId;
  bool _isLoaded = false;

  List<ScanHistoryModel> get scans =>
      List<ScanHistoryModel>.unmodifiable(_scans);
  int get totalScans => _scans.length;
  String? get currentUserId => _currentUserId;

  /// Loads scan history for a specific authenticated user ID.
  /// If the user is admin, loads platform-wide scan records.
  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;

    try {
      final prefs = await SharedPreferences.getInstance();

      if (userId == 'admin_001') {
        // Load all platform records
        final jsonString = prefs.getString(_keyPlatformScans);
        _scans.clear();
        if (jsonString != null && jsonString.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(jsonString);
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _scans.add(ScanHistoryModel.fromJson(item));
            }
          }
        } else {
          _scans.addAll(DummyScans.scans);
          await _persistPlatformScans(prefs);
        }
      } else {
        // Customer account: load isolated scan history
        final userKey = '$_userHistoryKeyPrefix$userId';
        final jsonString = prefs.getString(userKey);

        _scans.clear();
        if (jsonString != null && jsonString.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(jsonString);
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _scans.add(ScanHistoryModel.fromJson(item));
            }
          }
        } else if (userId == 'user_001' || userId == 'user_test_001') {
          // Demo customer gets initial demo scans
          _scans.addAll(DummyScans.scans);
          await _persistUserScans(prefs, userKey);
        } else {
          // Newly registered users start with an empty history
          _scans.clear();
        }
      }
    } catch (e) {
      debugPrint('Error loading scan history for user $userId: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Clears in-memory scans on logout so next account starts completely clean.
  void clearActiveUser() {
    _scans.clear();
    _currentUserId = null;
    notifyListeners();
  }

  /// Initializes the service by loading default scans from SharedPreferences.
  Future<void> init() async {
    if (_isLoaded && _scans.isNotEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final activeUser = AuthService.instance.currentUser;

      if (activeUser.id.isNotEmpty) {
        await loadForUser(activeUser.id);
        return;
      }

      final String? jsonString = prefs.getString(_keyPlatformScans);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _scans.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _scans.add(ScanHistoryModel.fromJson(item));
          }
        }
      } else {
        _scans.clear();
        _scans.addAll(DummyScans.scans);
      }
    } catch (e) {
      debugPrint('Error initializing scan history: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> addScan(ScanHistoryModel scan) async {
    _scans.insert(0, scan);
    notifyListeners();

    // Record the scan in the user's persistent profile (points + stats)
    AuthService.instance.recordScan(recyclable: scan.recyclable);

    await _persist();
  }

  Future<void> removeScan(String id) async {
    _scans.removeWhere((scan) => scan.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clearHistory() async {
    _scans.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist to user's isolated list
      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        final userKey = '$_userHistoryKeyPrefix$_currentUserId';
        await _persistUserScans(prefs, userKey);
      }

      // Also append to platform records so Admin can view overall platform scans
      final platformJson = prefs.getString(_keyPlatformScans);
      List<ScanHistoryModel> platformList = [];
      if (platformJson != null && platformJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(platformJson);
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            platformList.add(ScanHistoryModel.fromJson(item));
          }
        }
      } else {
        platformList = List.from(DummyScans.scans);
      }

      // Add to platform records if not already there
      for (final s in _scans) {
        if (!platformList.any((p) => p.id == s.id)) {
          platformList.insert(0, s);
        }
      }
      await prefs.setString(
        _keyPlatformScans,
        jsonEncode(platformList.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error persisting scan history: $e');
    }
  }

  Future<void> _persistUserScans(SharedPreferences prefs, String userKey) async {
    final listMap = _scans.map((s) => s.toJson()).toList();
    await prefs.setString(userKey, jsonEncode(listMap));
  }

  Future<void> _persistPlatformScans(SharedPreferences prefs) async {
    final listMap = _scans.map((s) => s.toJson()).toList();
    await prefs.setString(_keyPlatformScans, jsonEncode(listMap));
  }
}
