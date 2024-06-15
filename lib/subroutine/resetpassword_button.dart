import 'package:flutter/material.dart';

///UI介面登入按鈕

class Resetpasswordbutton extends StatelessWidget{
  final Function()? onTap;
  final String text;
  const Resetpasswordbutton({
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
        child: Center(
          child: Text(
            text,
            style:  const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}