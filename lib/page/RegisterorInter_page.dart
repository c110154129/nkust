import 'package:flutter/material.dart';
import 'Login_page.dart';
import "register_page.dart";

///選擇登入或註冊頁面

class RegisterorInterpage extends StatefulWidget {
  const RegisterorInterpage({super.key});

  @override
  State <RegisterorInterpage> createState() => _RegisterorInterpageState();
}
class _RegisterorInterpageState extends State<RegisterorInterpage> {
    bool showInterpage = true;

    void togglePages(){
      setState(() {
        showInterpage = !showInterpage;
      });
  }
  @override
  Widget build(BuildContext context){
      if (showInterpage) {
        return Interpage(
          onTap: togglePages,
        );
      }
      else{
        return Registerpage(
          onTap : togglePages,
        );
      }
  }
}
