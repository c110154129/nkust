import 'package:flutter/material.dart';

///Google and Apple 按鈕

class squarebutton  extends StatelessWidget{
  final String imagePath;
  final Function()?ontap;
  const  squarebutton({
    super.key,
    required this.imagePath,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: ontap,
      child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration:  BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white70),
            ),
          child:Center(
            child: Image.asset(
            imagePath,
            height: 55
          ),
          ),
      ),
    );
  }
}