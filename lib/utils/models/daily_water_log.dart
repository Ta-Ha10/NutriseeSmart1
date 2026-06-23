import 'water_intake_entry.dart';

class DailyWaterLog {
  final String dateString;
  final List<WaterIntakeEntry> entries;
  final int targetMl;

  const DailyWaterLog({
    required this.dateString,
    required this.entries,
    required this.targetMl,
  });

  factory DailyWaterLog.empty({
    required String dateString,
    required int targetMl,
  }) {
    return DailyWaterLog(
      dateString: dateString,
      entries: const [],
      targetMl: targetMl,
    );
  }

  factory DailyWaterLog.fromMap(String dateString, Map<String, dynamic>? data) {
    final rawEntries = data?['entries'];
    final entries = rawEntries is List
        ? rawEntries
              .whereType<Map>()
              .map(
                (entry) => WaterIntakeEntry.fromMap(
                  entry.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <WaterIntakeEntry>[];

    return DailyWaterLog(
      dateString: dateString,
      entries: entries,
      targetMl: _intValue(data?['targetMl']),
    );
  }

  int get consumedMl =>
      entries.fold(0, (total, entry) => total + entry.amountMl);
  int get remainingMl => _remaining(targetMl, consumedMl);
  double get progress => targetMl <= 0 ? 0 : consumedMl / targetMl;

  Map<String, dynamic> toMap() {
    return {
      'dateString': dateString,
      'targetMl': targetMl,
      'consumedMl': consumedMl,
      'remainingMl': remainingMl,
      'progress': progress,
      'entries': entries.map((entry) => entry.toMap()).toList(),
    };
  }

  static int _remaining(int target, int consumed) {
    final value = target - consumed;
    return value < 0 ? 0 : value;
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
}
