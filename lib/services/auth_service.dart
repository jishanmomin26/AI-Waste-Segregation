import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/admin_config.dart';
import '../data/dummy_users.dart';
import '../models/user_profile_model.dart';
import 'scan_history_service.dart';

/// Result object returned by auth operations for descriptive error handling,
/// while maintaining backward compatibility with boolean checks.
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  const AuthResult.success()
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage) : isSuccess = false;

  bool get success => isSuccess;

  @override
  bool operator ==(Object other) {
    if (other is bool) return isSuccess == other;
    if (other is AuthResult) {
      return isSuccess == other.isSuccess && errorMessage == other.errorMessage;
    }
    return false;
  }

  @override
  int get hashCode => isSuccess.hashCode;

  @override
  String toString() => isSuccess ? 'AuthResult.success' : 'AuthResult.failure($errorMessage)';
}

/// Internal account record stored persistently.
class AccountRecord {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String role; // 'user' | 'admin'
  final String phone;
  final String location;
  final String joinedDate;
  final int ecoPoints;
  final int totalScans;
  final int successfulScans;

  AccountRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.phone = '+91 98765 43210',
    this.location = 'Navi Mumbai',
    required this.joinedDate,
    this.ecoPoints = 50,
    this.totalScans = 0,
    this.successfulScans = 0,
  });

  UserProfileModel toUserProfileModel() {
    return UserProfileModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      location: location,
      joinedDate: joinedDate,
      ecoPoints: ecoPoints,
      totalScans: totalScans,
      successfulScans: successfulScans,
    );
  }

  AccountRecord copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? role,
    String? phone,
    String? location,
    String? joinedDate,
    int? ecoPoints,
    int? totalScans,
    int? successfulScans,
  }) {
    return AccountRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      joinedDate: joinedDate ?? this.joinedDate,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      totalScans: totalScans ?? this.totalScans,
      successfulScans: successfulScans ?? this.successfulScans,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role,
        'phone': phone,
        'location': location,
        'joinedDate': joinedDate,
        'ecoPoints': ecoPoints,
        'totalScans': totalScans,
        'successfulScans': successfulScans,
      };

  factory AccountRecord.fromJson(Map<String, dynamic> json) {
    return AccountRecord(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      location: json['location'] as String? ?? 'Navi Mumbai',
      joinedDate: json['joinedDate'] as String? ?? 'October 2026',
      ecoPoints: (json['ecoPoints'] as num?)?.toInt() ?? 50,
      totalScans: (json['totalScans'] as num?)?.toInt() ?? 0,
      successfulScans: (json['successfulScans'] as num?)?.toInt() ?? 0,
    );
  }
}

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyRole = 'auth_role';
  static const String _keyActiveUserId = 'auth_active_user_id';
  static const String _keyUserProfile = 'auth_user_profile';
  static const String _keyRegisteredAccounts = 'auth_registered_accounts_v2';

  static const String _salt = 'reccly_salt_2026_';

  // Authorized Admin Profile
  static final UserProfileModel _adminProfile = UserProfileModel(
    id: AdminConfig.authorizedAdminId,
    name: AdminConfig.authorizedAdminName,
    email: AdminConfig.authorizedAdminEmail,
    phone: '+91 98765 00000',
    location: 'HQ Central',
    joinedDate: 'September 2026',
    ecoPoints: 999,
    totalScans: 48,
    successfulScans: 48,
  );

  static const UserProfileModel _guestProfile = UserProfileModel(
    id: '',
    name: '',
    email: '',
    phone: '',
    location: '',
    joinedDate: '',
    ecoPoints: 0,
    totalScans: 0,
    successfulScans: 0,
  );

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String _role = 'user'; // 'user' | 'admin'
  UserProfileModel _currentUser = _guestProfile;
  final Map<String, AccountRecord> _registeredAccounts = {};

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  String get userRole => _role;
  bool get isAdmin => _role == 'admin';
  UserProfileModel get currentUser => _currentUser;

  /// Hashes a plain-text password with a salt using SHA-256.
  String _hashPassword(String password) {
    final bytes = utf8.encode('$_salt$password');
    return sha256.convert(bytes).toString();
  }

  /// Initializes the auth service, restores saved accounts and session.
  Future<void> init({bool force = false}) async {
    if (_isInitialized && !force) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load registered accounts
      await _loadAccountsFromPrefs(prefs);

      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _role = prefs.getString(_keyRole) ?? 'user';

      if (_isLoggedIn) {
        if (_role == 'admin') {
          _currentUser = _adminProfile;
          await ScanHistoryService.instance.loadForUser('admin_001');
        } else {
          final activeId = prefs.getString(_keyActiveUserId);
          AccountRecord? matchedAccount;

          if (activeId != null && activeId.isNotEmpty) {
            matchedAccount = _registeredAccounts.values
                .cast<AccountRecord?>()
                .firstWhere((acc) => acc?.id == activeId, orElse: () => null);
          }

          if (matchedAccount != null) {
            _currentUser = matchedAccount.toUserProfileModel();
          } else {
            // Fallback to saved profile JSON if available
            final profileJson = prefs.getString(_keyUserProfile);
            if (profileJson != null && profileJson.isNotEmpty) {
              final Map<String, dynamic> map = jsonDecode(profileJson);
              _currentUser = UserProfileModel.fromJson(map);
            } else {
              _currentUser = _guestProfile;
              _isLoggedIn = false;
            }
          }

          if (_isLoggedIn && _currentUser.id.isNotEmpty) {
            await ScanHistoryService.instance.loadForUser(_currentUser.id);
          }
        }
      } else {
        _currentUser = _guestProfile;
        _role = 'user';
        ScanHistoryService.instance.clearActiveUser();
      }
    } catch (e) {
      debugPrint('Error restoring auth session: $e');
      _isLoggedIn = false;
      _role = 'user';
      _currentUser = _guestProfile;
      ScanHistoryService.instance.clearActiveUser();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Loads accounts from SharedPreferences or seeds defaults if none exist.
  Future<void> _loadAccountsFromPrefs(SharedPreferences prefs) async {
    _registeredAccounts.clear();

    final jsonStr = prefs.getString(_keyRegisteredAccounts);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            _registeredAccounts[key.toLowerCase()] = AccountRecord.fromJson(value);
          }
        });
      } catch (e) {
        debugPrint('Error decoding accounts: $e');
      }
    }

    // Always ensure the single authorized Admin account is present and configured strictly
    _registeredAccounts[AdminConfig.authorizedAdminEmail.toLowerCase()] = AccountRecord(
      id: AdminConfig.authorizedAdminId,
      name: AdminConfig.authorizedAdminName,
      email: AdminConfig.authorizedAdminEmail,
      passwordHash: AdminConfig.authorizedAdminPasswordHash,
      role: 'admin',
      phone: '+91 98765 00000',
      location: 'HQ Central',
      joinedDate: 'September 2026',
      ecoPoints: 999,
      totalScans: 48,
      successfulScans: 48,
    );

    // Seed defaults if empty
    if (_registeredAccounts.length <= 1) {
      _seedDefaultAccounts();
      await _persistAccounts(prefs);
    }
  }

  void _seedDefaultAccounts() {
    // Admin Account (Configured via AdminConfig with zero plain-text password)
    _registeredAccounts[AdminConfig.authorizedAdminEmail.toLowerCase()] = AccountRecord(
      id: AdminConfig.authorizedAdminId,
      name: AdminConfig.authorizedAdminName,
      email: AdminConfig.authorizedAdminEmail,
      passwordHash: AdminConfig.authorizedAdminPasswordHash,
      role: 'admin',
      phone: '+91 98765 00000',
      location: 'HQ Central',
      joinedDate: 'September 2026',
      ecoPoints: 999,
      totalScans: 48,
      successfulScans: 48,
    );

    // Test Users
    _registeredAccounts['test@user.com'] = AccountRecord(
      id: 'user_test_001',
      name: 'Test User',
      email: 'test@user.com',
      passwordHash: _hashPassword('password123'),
      role: 'user',
      phone: '+91 98765 43210',
      location: 'Navi Mumbai',
      joinedDate: 'September 2026',
      ecoPoints: 240,
      totalScans: 12,
      successfulScans: 12,
    );

    _registeredAccounts['user@eco.com'] = AccountRecord(
      id: 'user_eco_002',
      name: 'Eco User',
      email: 'user@eco.com',
      passwordHash: _hashPassword('pass'),
      role: 'user',
      phone: '+91 98765 11223',
      location: 'Vashi',
      joinedDate: 'October 2026',
      ecoPoints: 50,
      totalScans: 0,
      successfulScans: 0,
    );

    _registeredAccounts['customer@eco.com'] = AccountRecord(
      id: 'user_cust_003',
      name: 'Eco Customer',
      email: 'customer@eco.com',
      passwordHash: _hashPassword('pass'),
      role: 'user',
      phone: '+91 98765 33445',
      location: 'Navi Mumbai',
      joinedDate: 'October 2026',
      ecoPoints: 50,
      totalScans: 0,
      successfulScans: 0,
    );

    // Seed users from DummyUsers
    for (final dummy in DummyUsers.users) {
      final normEmail = dummy.email.trim().toLowerCase();
      if (!_registeredAccounts.containsKey(normEmail)) {
        _registeredAccounts[normEmail] = AccountRecord(
          id: dummy.id,
          name: dummy.name.trim(),
          email: normEmail,
          passwordHash: _hashPassword('password123'),
          role: 'user',
          phone: dummy.phone,
          location: dummy.location,
          joinedDate: dummy.joinedDate,
          ecoPoints: dummy.ecoPoints,
          totalScans: dummy.totalScans,
          successfulScans: dummy.totalScans,
        );
      }
    }
  }

  Future<void> _persistAccounts(SharedPreferences prefs) async {
    final map = _registeredAccounts.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_keyRegisteredAccounts, jsonEncode(map));
  }

  /// Logs in as either customer or admin with strict credential and role checking.
  Future<AuthResult> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final normEmail = email.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (normEmail.isEmpty || trimmedPass.isEmpty) {
      return const AuthResult.failure('Please enter both email and password.');
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      if (role == 'admin') {
        // Enforce strict single authorized admin credentials
        if (!AdminConfig.isAuthorizedAdminEmail(normEmail)) {
          return const AuthResult.failure(
            'Administrator access denied. Only the configured administrator account is permitted to access the Admin Panel.',
          );
        }

        // Verify password using constant-time cryptographic hash verification
        final isValidPass = AdminConfig.verifyPassword(trimmedPass);
        if (!isValidPass) {
          return const AuthResult.failure('Invalid administrator credentials. Access denied.');
        }

        _isLoggedIn = true;
        _role = 'admin';
        _currentUser = _adminProfile;

        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyRole, 'admin');
        await prefs.setString(_keyActiveUserId, AdminConfig.authorizedAdminId);
        await prefs.setString(_keyUserProfile, jsonEncode(_adminProfile.toJson()));

        await ScanHistoryService.instance.loadForUser(AdminConfig.authorizedAdminId);

        notifyListeners();
        return const AuthResult.success();
      } else {
        // Customer login
        if (AdminConfig.isAuthorizedAdminEmail(normEmail)) {
          return const AuthResult.failure(
            'This email belongs to the administrator account. Please use the Admin Portal.',
          );
        }

        final account = _registeredAccounts[normEmail];
        if (account == null) {
          return const AuthResult.failure(
            'No registered account found with this email. Please create an account.',
          );
        }

        if (account.role != 'user') {
          return const AuthResult.failure('Access restricted for this account type.');
        }

        final hashedInput = _hashPassword(trimmedPass);
        final passwordMatches =
            account.passwordHash == hashedInput || account.passwordHash == trimmedPass;

        if (!passwordMatches) {
          return const AuthResult.failure('Incorrect password. Please try again.');
        }

        _isLoggedIn = true;
        _role = 'user';
        _currentUser = account.toUserProfileModel();

        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyRole, 'user');
        await prefs.setString(_keyActiveUserId, account.id);
        await prefs.setString(_keyUserProfile, jsonEncode(_currentUser.toJson()));

        await ScanHistoryService.instance.loadForUser(account.id);

        notifyListeners();
        return const AuthResult.success();
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Registers a new customer account, validates fields, and logs them in.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();
    final trimmedPass = password.trim();

    if (trimmedName.isEmpty || normEmail.isEmpty || trimmedPass.isEmpty) {
      return const AuthResult.failure('Please fill in all required fields.');
    }

    if (!normEmail.contains('@') || !normEmail.contains('.')) {
      return const AuthResult.failure('Please enter a valid email address.');
    }

    if (trimmedPass.length < 6) {
      return const AuthResult.failure('Password must be at least 6 characters.');
    }

    if (AdminConfig.isAuthorizedAdminEmail(normEmail)) {
      return const AuthResult.failure(
        'Cannot register with an administrator email address. Administrator accounts cannot be created publicly.',
      );
    }

    if (_registeredAccounts.containsKey(normEmail)) {
      return const AuthResult.failure(
        'An account with this email already exists. Please log in instead.',
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final joinedStr = '${months[now.month - 1]} ${now.year}';
      final newId = 'user_${now.millisecondsSinceEpoch}';

      final newAccount = AccountRecord(
        id: newId,
        name: trimmedName,
        email: normEmail,
        passwordHash: _hashPassword(trimmedPass),
        role: 'user', // Newly registered accounts are always user
        phone: '+91 98765 43210',
        location: 'Navi Mumbai',
        joinedDate: joinedStr,
        ecoPoints: 50, // Welcome bonus
        totalScans: 0,
        successfulScans: 0,
      );

      _registeredAccounts[normEmail] = newAccount;
      await _persistAccounts(prefs);

      _isLoggedIn = true;
      _role = 'user';
      _currentUser = newAccount.toUserProfileModel();

      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyRole, 'user');
      await prefs.setString(_keyActiveUserId, newId);
      await prefs.setString(_keyUserProfile, jsonEncode(_currentUser.toJson()));

      // Initialize empty scan history for new user
      await ScanHistoryService.instance.loadForUser(newId);

      notifyListeners();
      return const AuthResult.success();
    } catch (e) {
      debugPrint('Error during register: $e');
      return AuthResult.failure('Registration failed: $e');
    }
  }

  /// Updates current user profile details and persists across storage.
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
  }) async {
    final normEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    _currentUser = _currentUser.copyWith(
      name: trimmedName,
      email: normEmail,
      phone: phone.trim(),
      location: location.trim(),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserProfile, jsonEncode(_currentUser.toJson()));

      // Update in registered accounts
      final existingAccount = _registeredAccounts[normEmail] ??
          _registeredAccounts.values
              .cast<AccountRecord?>()
              .firstWhere((acc) => acc?.id == _currentUser.id, orElse: () => null);

      if (existingAccount != null) {
        _registeredAccounts[normEmail] = existingAccount.copyWith(
          name: trimmedName,
          email: normEmail,
          phone: phone.trim(),
          location: location.trim(),
        );
        await _persistAccounts(prefs);
      }
    } catch (e) {
      debugPrint('Error saving updated profile: $e');
    }

    notifyListeners();
  }

  /// Increments scan counts and eco points when a waste item is scanned.
  Future<void> recordScan({required bool recyclable}) async {
    final newPoints = _currentUser.ecoPoints + (recyclable ? 20 : 10);
    final newTotalScans = _currentUser.totalScans + 1;
    final newSuccessfulScans = _currentUser.successfulScans + (recyclable ? 1 : 0);

    _currentUser = _currentUser.copyWith(
      ecoPoints: newPoints,
      totalScans: newTotalScans,
      successfulScans: newSuccessfulScans,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserProfile, jsonEncode(_currentUser.toJson()));

      final normEmail = _currentUser.email.toLowerCase();
      final account = _registeredAccounts[normEmail];
      if (account != null) {
        _registeredAccounts[normEmail] = account.copyWith(
          ecoPoints: newPoints,
          totalScans: newTotalScans,
          successfulScans: newSuccessfulScans,
        );
        await _persistAccounts(prefs);
      }
    } catch (e) {
      debugPrint('Error recording scan in auth profile: $e');
    }

    notifyListeners();
  }

  /// Manually syncs scan statistics if needed.
  Future<void> syncScanStats(int scansCount, int pointsEarned) async {
    _currentUser = _currentUser.copyWith(
      totalScans: scansCount,
      ecoPoints: pointsEarned,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserProfile, jsonEncode(_currentUser.toJson()));
    } catch (e) {
      debugPrint('Error syncing scan stats: $e');
    }

    notifyListeners();
  }

  /// Explicit logout that clears saved authentication keys, resets in-memory
  /// user profile and isolates scan history so subsequent accounts are clean.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyRole);
      await prefs.remove(_keyActiveUserId);
      await prefs.remove(_keyUserProfile);
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoggedIn = false;
      _role = 'user';
      _currentUser = _guestProfile;
      ScanHistoryService.instance.clearActiveUser();
      notifyListeners();
    }
  }
}
