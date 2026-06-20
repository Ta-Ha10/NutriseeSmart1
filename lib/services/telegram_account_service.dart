import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/models/telegram_account.dart';

/// Service to manage Telegram account linking with Firebase users
class TelegramAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user UID
  String? _getCurrentUid() {
    return _auth.currentUser?.uid;
  }

  /// Link a Telegram account to the current user
  /// 
  /// Parameters:
  /// - telegramUserId: The Telegram user ID (from Telegram bot)
  /// - telegramUsername: The Telegram username handle
  /// - firstName: Optional Telegram first name
  /// - lastName: Optional Telegram last name
  /// 
  /// Returns: TelegramAccount if successful
  /// Throws: Exception if user not authenticated or linking fails
  Future<TelegramAccount> linkTelegramAccount({
    required String telegramUserId,
    required String telegramUsername,
    String? firstName,
    String? lastName,
  }) async {
    final uid = _getCurrentUid();
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final account = TelegramAccount(
      telegramUserId: telegramUserId,
      telegramUsername: telegramUsername,
      linkedAt: DateTime.now(),
      isActive: true,
      firstName: firstName,
      lastName: lastName,
    );

    try {
      // Store in users/{uid}/telegramAccounts/{telegramUserId}
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('telegramAccounts')
          .doc(telegramUserId)
          .set(account.toMap(), SetOptions(merge: true));

      // Also write flat field to user document for quick lookup
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
            'telegramChatId': telegramUserId,
          });

      // Create reference document with chatId as ID for direct lookup
      // usersByChatId/{chatId} -> { uid: uid, username: telegramUsername }
      await _firestore
          .collection('usersByChatId')
          .doc(telegramUserId)
          .set({
            'uid': uid,
            'telegramUsername': telegramUsername,
            'linkedAt': Timestamp.fromDate(DateTime.now()),
            'isActive': true,
          }, SetOptions(merge: true));

      return account;
    } catch (e) {
      throw Exception('Failed to link Telegram account: $e');
    }
  }

  /// Get linked Telegram account for current user
  /// Returns null if no account linked
  Future<TelegramAccount?> getTelegramAccount() async {
    final uid = _getCurrentUid();
    if (uid == null) return null;

    try {
      final query = await _firestore
          .collection('users')
          .doc(uid)
          .collection('telegramAccounts')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return TelegramAccount.fromMap(query.docs.first.data());
    } catch (e) {
      throw Exception('Failed to fetch Telegram account: $e');
    }
  }

  /// Get all linked Telegram accounts (active and inactive)
  Future<List<TelegramAccount>> getAllTelegramAccounts() async {
    final uid = _getCurrentUid();
    if (uid == null) return [];

    try {
      final query = await _firestore
          .collection('users')
          .doc(uid)
          .collection('telegramAccounts')
          .get();

      return query.docs
          .map((doc) => TelegramAccount.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch Telegram accounts: $e');
    }
  }

  /// Check if a specific Telegram account is linked
  Future<bool> isTelegramLinked(String telegramUserId) async {
    final uid = _getCurrentUid();
    if (uid == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('telegramAccounts')
          .doc(telegramUserId)
          .get();

      return doc.exists && (doc.data()?['isActive'] ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Update last used timestamp for tracking activity
  Future<void> updateLastUsed(String telegramUserId) async {
    final uid = _getCurrentUid();
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('telegramAccounts')
          .doc(telegramUserId)
          .update({
        'lastUsedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail for activity tracking
    }
  }

  /// Deactivate (unlink) a Telegram account
  Future<void> unlinkTelegramAccount(String telegramUserId) async {
    final uid = _getCurrentUid();
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('telegramAccounts')
          .doc(telegramUserId)
          .update({
        'isActive': false,
      });

      // Remove flat field from user document
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
            'telegramChatId': FieldValue.delete(),
          });

      // Remove from usersByChatId reference collection
      await _firestore
          .collection('usersByChatId')
          .doc(telegramUserId)
          .delete();
    } catch (e) {
      throw Exception('Failed to unlink Telegram account: $e');
    }
  }

  /// Watch for Telegram account changes (real-time)
  Stream<TelegramAccount?> watchTelegramAccount() {
    final uid = _getCurrentUid();
    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('telegramAccounts')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((query) {
      if (query.docs.isEmpty) return null;
      return TelegramAccount.fromMap(query.docs.first.data());
    });
  }

  /// Get Telegram account by user ID (used by n8n to look up user preferences)
  /// This method is for n8n workflows to verify user exists
  /// 
  /// Note: In production, this should be protected by Firebase rules
  /// n8n should call via a secure Cloud Function wrapper
  Future<String?> getUserIdByTelegramId(String telegramUserId) async {
    try {
      // Query across all users for this Telegram ID
      // In production, use a Cloud Function for security
      final query = await _firestore
          .collectionGroup('telegramAccounts')
          .where('telegramUserId', isEqualTo: telegramUserId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      // Extract uid from document path: users/{uid}/telegramAccounts/{telegramId}
      final path = query.docs.first.reference.path;
      final uid = path.split('/')[1];
      return uid;
    } catch (e) {
      // Failed to look up user - log might be stored elsewhere
      return null;
    }
  }

  /// Stream Telegram account changes from personalData.telegramChatId field
  /// This listens for real-time changes when bot links an account
  /// 
  /// Returns a stream of TelegramAccount or null if not linked
  Stream<TelegramAccount?> streamTelegramAccountFromPersonalData() {
    final uid = _getCurrentUid();
    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((userDoc) async {
      // Get telegramChatId from personalData
      final telegramChatId = userDoc.data()?['personalData']?['telegramChatId'];

      if (telegramChatId == null || telegramChatId.toString().isEmpty) {
        return null;
      }

      try {
        // Fetch full account details from telegramAccounts subcollection
        final accountDoc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('telegramAccounts')
            .doc(telegramChatId.toString())
            .get();

        if (accountDoc.exists) {
          return TelegramAccount.fromMap(accountDoc.data()!);
        }
        return null;
      } catch (e) {
        // If fetch fails, return null
        return null;
      }
    });
  }

  /// Get Telegram account by chat ID (search across all users)
  /// Returns the TelegramAccount for the given chat ID
  /// 
  /// Parameters:
  /// - chatId: The Telegram chat ID to search for
  /// 
  /// Returns: TelegramAccount if found, null otherwise
  Future<TelegramAccount?> getTelegramAccountByChatId(String chatId) async {
    try {
      final query = await _firestore
          .collectionGroup('telegramAccounts')
          .where('telegramUserId', isEqualTo: chatId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return TelegramAccount.fromMap(query.docs.first.data());
    } catch (e) {
      throw Exception('Failed to fetch account by chat ID: $e');
    }
  }

  /// Get user UID from Telegram chat ID (fast lookup)
  /// Uses the usersByChatId reference collection for O(1) lookup
  /// 
  /// Parameters:
  /// - chatId: The Telegram chat ID to search for
  /// 
  /// Returns: User UID if found, null otherwise
  /// Throws: Exception if lookup fails
  Future<String?> getUserIdByChatId(String chatId) async {
    try {
      final doc = await _firestore
          .collection('usersByChatId')
          .doc(chatId)
          .get();

      if (!doc.exists) return null;
      return doc.data()?['uid'] as String?;
    } catch (e) {
      throw Exception('Failed to lookup user by chat ID: $e');
    }
  }
}
