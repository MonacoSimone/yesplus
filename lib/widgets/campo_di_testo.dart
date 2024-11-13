import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CampoDiTesto extends StatelessWidget {
  CampoDiTesto(
      {super.key,
      required this.text,
      this.left = 15,
      this.bottom = 0,
      this.right = 0,
      this.top = 0,
      this.width = 200,
      required this.controller,
      required this.val,
      this.style = const TextStyle(fontSize: 14, color: Colors.black)});

  String text;
  TextStyle style;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final TextEditingController controller;
  RxString val;

  @override
  Widget build(BuildContext context) {
    controller.text = val.value;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text, style: style),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            onChanged: (value) {
              controller.text = value;
            },
          ),
        )
      ],
    );
  }
}
