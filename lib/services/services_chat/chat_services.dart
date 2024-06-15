import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nkust/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream to get all users from Firestore
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  /// Method to send a message
  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // 確認是否有聊天室若無則新建一個
    final chatRoomID = _generateChatRoomID(currentUserID, receiverID);
    final chatRoomDoc = _firestore.collection("chat_rooms").doc(chatRoomID);
    final chatRoomExists = await chatRoomDoc.get().then((doc) => doc.exists);

    if (!chatRoomExists) {
      await _createChatRoom(chatRoomID, currentUserID, receiverID);
    }

    await chatRoomDoc.collection("messages").add(newMessage.toMap());
  }

  /// Generate chat room ID from two user IDs
  String _generateChatRoomID(String userID1, String userID2) {
    List<String> ids = [userID1, userID2];
    ids.sort();
    return ids.join('_');
  }

  /// Create a new chat room and add users to it
  Future<void> _createChatRoom(String chatRoomID, String userID1, String userID2) async {
    final chatRoomData = {
      "users": [userID1, userID2],
    };
    await _firestore.collection("chat_rooms").doc(chatRoomID).set(chatRoomData);
  }

  /// Stream to get messages between two users
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    final chatRoomID = _generateChatRoomID(userID, otherUserID);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Check if a user has chat history with any other user
  Future<bool> hasChatHistory(String userID) async {
    final querySnapshot = await _firestore
        .collection("chat_rooms")
        .where("users", arrayContains: userID)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}