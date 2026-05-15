import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/features/chat/models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return uid;
  }

  Future<void> saveChatMessage({
    required String message,
    required String response,
  }) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatHistory')
        .add({
      'message': message,
      'response': response,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatMessage>> getChatHistory() {
    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('chatHistory')
          .orderBy('timestamp', descending: false)
          .limitToLast(50)
          .snapshots()
          .map((snapshot) {
        final List<ChatMessage> history = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          history.add(ChatMessage(
            text: data['message'] ?? '',
            isUser: true,
          ));
          history.add(ChatMessage(
            text: data['response'] ?? '',
            isUser: false,
          ));
        }
        return history;
      });
    } catch (e) {
      if (e is StateError) return Stream.value([]);
      rethrow;
    }
  }

  Future<void> clearChatHistory() async {
    final batch = _firestore.batch();
    final chats = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatHistory')
        .get();

    for (var doc in chats.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
