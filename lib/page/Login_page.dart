import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust/services/auth_services.dart';
import 'package:nkust/subroutine/inter_button.dart';
import 'package:nkust/subroutine/my_extField.dart';
import 'package:nkust/subroutine/register_button.dart';
import 'package:nkust/services/Google.dart';
import 'Forgotpassword_page.dart';

/// 登入頁面

class Interpage extends StatefulWidget {
  final Function()? onTap;
  Interpage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<Interpage> createState() => _InterpageState();
}

class _InterpageState extends State<Interpage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void signUserIn() async {
    final authService = AuthServices();
    setState(() {
      isLoading = true;
    });
    try {
      await authService.signInWithEmailPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('登入失敗'),
        content: Text('帳號或密碼錯誤'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 70),
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: '帳號',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: '密碼',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ForgotPasswordpage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          '忘記密碼?',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Interbutton(
                  text: "登入",
                  onTap: isLoading ? null : signUserIn,
                ),
                SizedBox(height: 5),
                Registerbutton(
                  text: "註冊帳號",
                  onTap: widget.onTap,
                ),
                SizedBox(height: 15),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey[500],
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "其他登入方式",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Google().signInWithGoogle(),
                      child: Image.asset(
                        'lib/images/google.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    SizedBox(width: 25),
                    // squarebutton(
                    //   ontap: () {},
                    //   imagePath: 'lib/images/apple.png'
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}