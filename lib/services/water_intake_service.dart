import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/models/daily_water_log.dart';
import '../utils/models/water_intake_entry.dart';

class WaterIntakeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String dateString([DateTime? date]) {
    final value = date ?? DateTime.now();
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static Stream<DailyWaterLog> watchTodayLog({
    required String uid,
    required int targetMl,
  }) {
    final today = dateString();
    return _dailyDoc(uid, today).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return DailyWaterLog.empty(dateString: today, targetMl: targetMl);
      }

      final log = DailyWaterLog.fromMap(today, snapshot.data());
      return log.targetMl > 0
          ? log
          : DailyWaterLog(
              dateString: today,
              entries: log.entries,
              targetMl: targetMl,
            );
    });
  }

  static Future<List<DailyWaterLog>> getLogsForRange({
    required String uid,
    required DateTime start,
    required DateTime end,
    required int targetMl,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyWater')
        .get();

    final startKey = dateString(start);
    final endKey = dateString(end);

    final logs = snapshot.docs
        .where(
          (doc) =>
              doc.id.compareTo(startKey) >= 0 && doc.id.compareTo(endKey) <= 0,
        )
        .map((doc) {
          final log = DailyWaterLog.fromMap(doc.id, doc.data());
          return log.targetMl > 0
              ? log
              : DailyWaterLog(
                  dateString: log.dateString,
                  entries: log.entries,
                  targetMl: targetMl,
                );
        })
        .toList();

    logs.sort((a, b) => a.dateString.compareTo(b.dateString));
    return logs;
  }

  static Future<void> logWaterIntake({
    required String uid,
    required int amountMl,
    required int targetMl,
  }) async {
    final today = dateString();
    final docRef = _dailyDoc(uid, today);
    final now = DateTime.now();
    final entry = WaterIntakeEntry(
      id: '${now.microsecondsSinceEpoch}',
      amountMl: amountMl,
      loggedAt: now,
    );

    await docRef.set({
      'dateString': today,
      'targetMl': targetMl,
      'entries': FieldValue.arrayUnion([entry.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> resetToday({
    required String uid,
    required int targetMl,
  }) async {
    final today = dateString();
    await _dailyDoc(uid, today).set({
      'dateString': today,
      'targetMl': targetMl,
      'consumedMl': 0,
      'remainingMl': targetMl,
      'progress': 0,
      'entries': <Map<String, dynamic>>[],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static DocumentReference<Map<String, dynamic>> _dailyDoc(
    String uid,
    String date,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyWater')
        .doc(date);
  }
}
