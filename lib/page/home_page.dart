// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nkust/page/draw_straws_page.dart';
import 'package:nkust/page/profile_page.dart';
import 'package:nkust/services/auth_services.dart';
import 'dart:async';
import '../avtivities/AddEventPage.dart';
import '../avtivities/EventDetailPage.dart';
import '../book/addBookScreen.dart';
import '../book/bookDetailScreen.dart';
import 'choosechat_page.dart';

///主頁

class Homepage extends StatelessWidget {
  final int initialTabIndex;
  Homepage({this.initialTabIndex = 0});

  ///登出
  Future signUserOut() async {
   final auth =AuthServices();
    auth.signOut();
    await GoogleSignIn.games().signOut();
  }
    ///活動
    Widget _buildEventsTab(BuildContext context) {
      return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').
          orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            List<DocumentSnapshot> events = snapshot.data!.docs;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> eventData = events[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    leading: Image.network(eventData['imageUrl'], width: 120, height: 120, fit: BoxFit.cover),
                    title: Text(eventData['name'], style: const TextStyle(fontSize: 20)),
                    tileColor: Colors.blueGrey[100],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(eventData),),);},
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const AddEventPage() ));},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('添加活動', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              backgroundColor: Colors.green[300],),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, //右下角
      );
    }

    ///二手書
    Widget _buildSecondHandBooksTab(BuildContext context) {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('books')
              .orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 加载中的圆形数据条
            }
            List<DocumentSnapshot> books = snapshot.data!.docs;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> bookData = books[index].data() as Map<String, dynamic>;
                bookData['id'] = books[index].id;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    leading: Image.network(bookData['imageUrl'], width: 120, height: 120, fit: BoxFit.cover),
                    title: Text(bookData['title'], style: const TextStyle(fontSize: 20)),
                    tileColor: Colors.blueGrey[100],
                    onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => BookDetailScreen(bookData),
                        ));
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddBookScreen()));
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('添加新書', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              backgroundColor: Colors.green[300],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 右下角
      );
    }

    ///抽籤
    Widget _buildDrawTab(BuildContext context) {
      return LotteryScreen();
    }

    ///UI介面
    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
        initialIndex: initialTabIndex,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green[800],
            title: const Text("學生交流互動平台",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
            bottom: const TabBar(
              unselectedLabelColor: Colors.white,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: "活動",
                    icon: Icon(Icons.party_mode_sharp)),
                Tab(text: "二手書",
                    icon: Icon(Icons.book)),
                Tab(text: "抽籤",
                    icon: Icon(Icons.food_bank)),
              ],
            ),
          ),
          drawer: Drawer(
            child: Container(
              color: Colors.green[700],
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ListTile(
                      leading: const Icon(Icons.chat,
                          color: Colors.black),
                      title: const Text('聊天'),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                            return ChooseChatpage();},
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ListTile(
                      leading: const Icon(Icons.person,
                          color: Colors.black),
                      title: const Text('個人資料'),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const ProfilePage();},
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ListTile(
                      leading: const Icon(Icons.logout,
                          color: Colors.black),
                    title: const Text('登出'),
                    onTap: signUserOut,),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildEventsTab(context),
              _buildSecondHandBooksTab(context),
              _buildDrawTab(context),
            ],
          ),
        ),
      );
    }
}