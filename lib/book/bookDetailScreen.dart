import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../page/Chat_page.dart';
import 'editBookScreen.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const BookDetailScreen(this.bookData, {super.key});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Map<String, dynamic> _bookData;

  @override
  void initState() {
    super.initState();
    _bookData = widget.bookData;
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('書籍'),
        ),
        body: const Center(
          child: Text('沒有用戶登入'),
        ),
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(_bookData['userUID']).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('書籍'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (userSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('書籍'),
            ),
            body: Center(
              child: Text('錯誤: ${userSnapshot.error}'),
            ),
          );
        }

        final sellerName = userSnapshot.hasData && userSnapshot.data!.exists
            ? userSnapshot.data!.get('name')
            : _bookData['userEmail'];
        final isSeller = currentUser.uid == _bookData['userUID'];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('books').doc(_bookData['id']).get(),
          builder: (context, bookSnapshot) {
            if (bookSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('書籍'),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (bookSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('書籍'),
                ),
                body: Center(
                  child: Text('錯誤: ${bookSnapshot.error}'),
                ),
              );
            }

            final bookDoc = bookSnapshot.data;
            final bookTitle = bookDoc != null ? bookDoc['title'] : _bookData['title'];
            final bookAuthor = bookDoc != null ? bookDoc['author'] : _bookData['author'];
            final bookYear = bookDoc != null ? bookDoc['year'] : _bookData['year'];
            final bookDescription = bookDoc != null ? bookDoc['description'] : _bookData['description'];
            final bookID = _bookData['id'];

            return Scaffold(
              appBar: AppBar(
                title: const Text('書籍'),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_bookData.containsKey('imageUrl'))
                        Image.network(
                          _bookData['imageUrl'],
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 20),
                      Text('書名: $bookTitle', style: const TextStyle(fontSize: 20)),
                      Text('作者: $bookAuthor', style: const TextStyle(fontSize: 20)),
                      Text('年份: $bookYear', style: const TextStyle(fontSize: 20)),
                      Text('描述: $bookDescription', style: const TextStyle(fontSize: 20)),
                      Text('賣家: $sellerName', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  if (isSeller) {
                    final updatedBookData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBookScreen(bookData: _bookData),
                      ),
                    );
                    if (updatedBookData != null) {
                      setState(() {
                        _bookData = updatedBookData;
                      });
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatpage(
                          receiverEmail: _bookData['userEmail'],
                          receiverID: _bookData['userUID'],
                        ),
                      ),
                    );
                  }
                },
                tooltip: isSeller ? '編輯' : '聊天',
                child: Icon(isSeller ? Icons.edit : Icons.chat),
              ),
            );
          },
        );
      },
    );
  }
}
