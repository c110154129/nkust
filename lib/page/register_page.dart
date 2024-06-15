import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust/services/auth_services.dart';
import 'package:nkust/subroutine/inter_button.dart';
import 'package:nkust/subroutine/my_extField.dart';
import 'package:nkust/subroutine/register_button.dart';

///註冊頁面

class Registerpage extends StatefulWidget {
  final Function()? onTap;
  const Registerpage({super.key, required this.onTap});
  @override
  State <Registerpage> createState() => _RegisterpageState();
}
class _RegisterpageState extends State<Registerpage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final checkpasswordController = TextEditingController();

  void signUserUp() async{
    final _auth = AuthServices();
    showDialog(
      context: context,
        builder: (context){
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      if(passwordController.text == checkpasswordController.text) {
        await _auth.signUpWithEmailPassword(
          emailController.text,
          passwordController.text
        );
        Navigator.pop(context);
      }
    }
    catch(e) {
      Navigator.pop(context);
      showErrorMessage(e.toString());
    }
  }
  void showErrorMessage(String message){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(

        title: const Text('註冊失敗'),

        content: const Text('重新檢查帳號或密碼'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body:   SafeArea(
        child:SingleChildScrollView(
          child:Center(
            child: Column(
              children: [
                const SizedBox(height:70),
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: emailController,
                  hintText: '註冊帳號',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: '密碼(6位數以上)',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: checkpasswordController,
                  hintText: '確認密碼',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                Interbutton(
                  text:"註冊",
                  onTap: signUserUp,
                ),
                const SizedBox(height: 5),
                Registerbutton(
                  text:"登入帳號",
                  onTap:widget.onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}