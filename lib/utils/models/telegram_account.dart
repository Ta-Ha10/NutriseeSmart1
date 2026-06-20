import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a linked Telegram account for a user
class TelegramAccount {
  final String telegramUserId;
  final String telegramUsername;
  final DateTime linkedAt;
  final DateTime? lastUsedAt;
  final bool isActive;
  final String? firstName;
  final String? lastName;

  const TelegramAccount({
    required this.telegramUserId,
    required this.telegramUsername,
    required this.linkedAt,
    this.lastUsedAt,
    this.isActive = true,
    this.firstName,
    this.lastName,
  });

  /// Get full name from first and last name
  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ').trim();
  }

  /// Create from Firestore data
  factory TelegramAccount.fromMap(Map<String, dynamic> data) {
    return TelegramAccount(
      telegramUserId: _stringValue(data['telegramUserId']) ?? '',
      telegramUsername: _stringValue(data['telegramUsername']) ?? '',
      linkedAt: _dateValue(data['linkedAt']),
      lastUsedAt: data['lastUsedAt'] == null ? null : _dateValue(data['lastUsedAt']),
      isActive: _boolValue(data['isActive'], true),
      firstName: _stringValue(data['firstName']),
      lastName: _stringValue(data['lastName']),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'telegramUserId': telegramUserId,
      'telegramUsername': telegramUsername,
      'linkedAt': Timestamp.fromDate(linkedAt),
      if (lastUsedAt != null) 'lastUsedAt': Timestamp.fromDate(lastUsedAt!),
      'isActive': isActive,
      if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
      if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
    };
  }

  /// Update last used timestamp
  TelegramAccount copyWithLastUsed(DateTime now) {
    return TelegramAccount(
      telegramUserId: telegramUserId,
      telegramUsername: telegramUsername,
      linkedAt: linkedAt,
      lastUsedAt: now,
      isActive: isActive,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Deactivate account
  TelegramAccount copyWithInactive() {
    return TelegramAccount(
      telegramUserId: telegramUserId,
      telegramUsername: telegramUsername,
      linkedAt: linkedAt,
      lastUsedAt: lastUsedAt,
      isActive: false,
      firstName: firstName,
      lastName: lastName,
    );
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool _boolValue(dynamic value, bool defaultValue) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static DateTime _dateValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
