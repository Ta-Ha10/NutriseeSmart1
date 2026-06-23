import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeEntry {
  final String id;
  final int amountMl;
  final DateTime loggedAt;

  const WaterIntakeEntry({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  factory WaterIntakeEntry.fromMap(Map<String, dynamic> data) {
    return WaterIntakeEntry(
      id: _stringValue(data['id']) ?? '',
      amountMl: _intValue(data['amountMl']),
      loggedAt: _dateValue(data['loggedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amountMl': amountMl,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _intValue(dynamic value) {
    if (value is num) return value.round();
    if (value is String) {
      final direct = int.tryParse(value.trim());
      if (direct != null) return direct;
      final match = RegExp(r'-?\d+').firstMatch(value);
      if (match != null) return int.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }

  static DateTime _dateValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
