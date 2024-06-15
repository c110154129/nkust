import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nkust/services/auth_services.dart';
import 'package:nkust/services/services_chat/chat_services.dart';
import 'package:nkust/subroutine/chat_bubble.dart';
import 'package:nkust/subroutine/my_extField.dart';

class Chatpage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;


   Chatpage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
 });

 final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthServices _authServices = AuthServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserName(String userID) async {
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userID).get();
    return userDoc['name'];
  }

  void sendMessage()async{
    if(_messageController.text.isNotEmpty){
      await _chatService.sendMessage(
          receiverID,
          _messageController.text
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: getUserName(receiverID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            }
            if (snapshot.hasError) {
              return Text("Error");
            }
            return Text(snapshot.data ?? receiverEmail);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }


  Widget _buildMessageList(){
    String senderID = _authServices.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(receiverID, senderID),
        builder: (context,snapshot){
          if(snapshot.hasError){
            return const Text("Error");
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading...");
          }
          return ListView(
            children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          );
        },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc){Map<String, dynamic> data =
    doc.data() as Map<String, dynamic>;

    bool isCurrenUser = data["senderID"] == _authServices.getCurrentUser()!.uid;

    var alignment =
        isCurrenUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment:alignment,
      child: Column(
        crossAxisAlignment:
          isCurrenUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children:[
          ChatBubble(message: data['message'],
              isCurrentUser: isCurrenUser,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(){
    return Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
                controller:_messageController,
                hintText:"發送訊息...",
                obscureText: false,
              ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin:  const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}