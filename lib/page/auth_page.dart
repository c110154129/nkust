import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nkust/page/RegisterorInter_page.dart';
import 'package:nkust/page/home_page.dart';

///登入後進入主頁否則進入登入or註冊頁面

class Authpage extends StatelessWidget {
     const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //user is logged in
          if(snapshot.hasData){
            return  Homepage();
          }
          //user in not logged in
          else{
            return  RegisterorInterpage();
          }
        },
      ),
    );
  }
}