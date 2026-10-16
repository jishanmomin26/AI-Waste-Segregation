import 'package:flutter/foundation.dart';

import '../data/dummy_centers.dart';
import '../data/dummy_notifications.dart';
import '../data/dummy_users.dart';
import '../data/dummy_waste.dart';
import '../models/notification_model.dart';
import '../models/recycling_center_model.dart';
import '../models/user_model.dart';
import '../models/waste_model.dart';

class MockDataService extends ChangeNotifier {
  MockDataService._internal()
      : _categories = List<WasteModel>.from(DummyWaste.categories),
        _centers = List<RecyclingCenterModel>.from(DummyCenters.centers),
        _users = List<UserModel>.from(DummyUsers.users),
        _notifications =
            List<NotificationModel>.from(DummyNotifications.notifications);

  static final MockDataService instance = MockDataService._internal();

  final List<WasteModel> _categories;
  final List<RecyclingCenterModel> _centers;
  final List<UserModel> _users;
  final List<NotificationModel> _notifications;

  // Getters
  List<WasteModel> get categories => List.unmodifiable(_categories);
  List<WasteModel> get wasteCategories => categories;
  List<RecyclingCenterModel> get centers => List.unmodifiable(_centers);
  List<UserModel> get users => List.unmodifiable(_users);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  // Waste Categories Management
  void addCategory(WasteModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void addWasteCategory(WasteModel category) => addCategory(category);

  void updateCategory(WasteModel updatedCategory) {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      notifyListeners();
    }
  }

  void updateWasteCategory(WasteModel updatedCategory) =>
      updateCategory(updatedCategory);

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void deleteWasteCategory(String id) => deleteCategory(id);

  // Recycling Centers Management
  void addCenter(RecyclingCenterModel center) {
    _centers.add(center);
    notifyListeners();
  }

  void updateCenter(RecyclingCenterModel updatedCenter) {
    final index = _centers.indexWhere((c) => c.id == updatedCenter.id);
    if (index != -1) {
      _centers[index] = updatedCenter;
      notifyListeners();
    }
  }

  void deleteCenter(String id) {
    _centers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // User Management
  void toggleUserStatus(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final current = _users[index];
      _users[index] = UserModel(
        id: current.id,
        name: current.name,
        email: current.email,
        phone: current.phone,
        location: current.location,
        joinedDate: current.joinedDate,
        totalScans: current.totalScans,
        ecoPoints: current.ecoPoints,
        active: !current.active,
      );
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  // Notifications Management
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final current = _notifications[index];
      _notifications[index] = NotificationModel(
        id: current.id,
        title: current.title,
        message: current.message,
        type: current.type,
        date: current.date,
        time: current.time,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      final current = _notifications[i];
      _notifications[i] = NotificationModel(
        id: current.id,
        title: current.title,
        message: current.message,
        type: current.type,
        date: current.date,
        time: current.time,
        isRead: true,
      );
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
