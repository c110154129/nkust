import 'package:flutter/material.dart';

///UI介面註冊按鈕

class Registerbutton extends StatelessWidget{
  final Function()? onTap;
  final String text;
  const Registerbutton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context){
    return  GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[500],
          borderRadius: BorderRadius.circular(8),
        ),
        child:  Center(
          child:
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}