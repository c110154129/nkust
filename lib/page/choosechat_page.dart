import 'package:flutter/material.dart';
import 'package:nkust/services/auth_services.dart';
import 'package:nkust/services/services_chat/chat_services.dart';
import 'package:nkust/subroutine/user_tile.dart';
import 'Chat_page.dart';

class ChooseChatpage extends StatelessWidget {
  ChooseChatpage({super.key});

  final ChatService _chatService = ChatService();
  final AuthServices _authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "聊天室",
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey[600],
        elevation: 0,
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        List<Map<String, dynamic>> users = snapshot.data!.where((userData) {
          final email = userData["email"] as String?;
          return email != null && (email.endsWith('@nkust.edu.tw') || email.endsWith('@gmail.com'));
        }).toList();

        final currentUserID = _authServices.getCurrentUser()?.uid;

        return FutureBuilder(
          future: Future.wait(users.map((user) async {
            final hasChatHistory = await _chatService.hasChatHistory(user["uid"]);
            return hasChatHistory || user["uid"] == currentUserID ? user : null;
          }).toList()),
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>?>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final usersWithChatHistory = snapshot.data!.whereType<Map<String, dynamic>>().toList();

            if (usersWithChatHistory.isEmpty) {
              return const Center(child: Text("尚未與其他用戶聊天", style: TextStyle(fontSize: 15)));
            }

            return ListView.builder(
              itemCount: usersWithChatHistory.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> userData = usersWithChatHistory[index];
                String displayName = userData.containsKey("name") &&
                                      userData["name"] != null &&
                                      userData["name"].trim().isNotEmpty ? userData["name"] :
                userData["email"];
                return UserTile(
                  text: displayName,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatpage(
                          receiverEmail: userData["email"],
                          receiverID: userData["uid"],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}