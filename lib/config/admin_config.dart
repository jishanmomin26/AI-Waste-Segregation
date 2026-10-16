import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Secure configuration and credential verification for the single authorized
/// Administrator account in Recycle App / EcoSort AI.
///
/// Production Security Rules:
/// 1. NEVER store plain-text passwords in the source code or binary.
/// 2. Only the pre-computed salted cryptographic hash (SHA-256) is stored.
/// 3. Supports build-time configuration via `--dart-define` for CI/CD environments.
/// 4. Employs constant-time string comparison to prevent timing attacks.
class AdminConfig {
  AdminConfig._();

  /// Unique immutable identifier for the single authorized Admin.
  static const String authorizedAdminId = 'admin_001';

  /// Official display name for the authorized administrator.
  static const String authorizedAdminName = 'Reccly Admin';

  /// Specifically configured Administrator email address.
  /// Can be overridden at build-time using:
  /// `--dart-define=ADMIN_EMAIL=your_admin@gmail.com`
  static const String authorizedAdminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'admin@gmail.com',
  );

  /// Cryptographic salt specifically reserved for Admin credential hashing.
  /// Can be overridden at build-time using:
  /// `--dart-define=ADMIN_SALT=your_secure_salt_`
  static const String adminSalt = String.fromEnvironment(
    'ADMIN_SALT',
    defaultValue: 'reccly_admin_secure_salt_2026_',
  );

  /// Pre-computed SHA-256 cryptographic hash of the authorized Admin password.
  /// No plain-text password exists anywhere in this codebase.
  /// Pre-computed hash corresponds to SHA-256 of:
  ///   `reccly_admin_secure_salt_2026_` + `<configured_admin_password>`
  ///
  /// To configure a custom password in production, generate its SHA-256 hash:
  ///   hash = SHA-256(ADMIN_SALT + NEW_PASSWORD)
  /// And provide at compile time:
  ///   `--dart-define=ADMIN_PASSWORD_HASH=<hash>`
  static const String authorizedAdminPasswordHash = String.fromEnvironment(
    'ADMIN_PASSWORD_HASH',
    defaultValue: '10e9452b7c474a373a6f8ab18ee71f170ab7421cb45bb8ed3a8134de0c7e9bc3',
  );

  /// Computes the salted SHA-256 hash for an entered candidate password.
  static String hashCandidatePassword(String rawPassword) {
    final bytes = utf8.encode('$adminSalt$rawPassword');
    return sha256.convert(bytes).toString();
  }

  /// Verifies an entered password against the configured admin password hash.
  /// Uses constant-time comparison to prevent timing attacks.
  static bool verifyPassword(String enteredPassword) {
    if (enteredPassword.isEmpty) return false;
    final candidateHash = hashCandidatePassword(enteredPassword.trim());
    return _constantTimeCompare(candidateHash, authorizedAdminPasswordHash);
  }

  /// Constant-time string comparison preventing side-channel timing leaks.
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Validates whether an email matches the single authorized administrator email.
  static bool isAuthorizedAdminEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized == authorizedAdminEmail.toLowerCase();
  }
}
