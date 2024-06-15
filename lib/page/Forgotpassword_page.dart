import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../subroutine/my_extField.dart';
import '../subroutine/resetpassword_button.dart';

class ForgotPasswordpage extends StatefulWidget{
  const ForgotPasswordpage({super.key});
  @override
  State<ForgotPasswordpage> createState() =>_ForgotPasswordpageState();
}
class _ForgotPasswordpageState extends State<ForgotPasswordpage>{
  final emailController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    super.dispose() ;}
  Future passwordreset() async{
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
       showDialog(
         context: context,
         builder: (context){
          return const AlertDialog(
           content: Text('重製密碼連結已傳送,請檢察您的電子郵件'),);
         },
       );
    }
    on FirebaseAuthException catch(e) {
      showErrorMessage(e.code);
    }
  }
  void showErrorMessage(String message){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('錯誤'),
        content: const Text('請重新檢查帳號'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              // 關閉此通知
              Navigator.pop(context);
            },
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Colors.grey[350],
        elevation: 0,
      ),
      body: Column(
       children:[
         const Text(
              "尋找您的密碼",
              style:TextStyle(fontSize: 20)
              ),
         const Text(
             "請輸入您的帳號",
              style:TextStyle(fontSize: 15),
         ),
         const SizedBox(height: 15),
         MyTextField(
           controller: emailController,
           hintText: '帳號',
           obscureText: false,
         ),
         const SizedBox(height: 15),
         Resetpasswordbutton(
           text:'繼續',
           onTap:passwordreset,
         )
       ],
      ),
    );
  }
}