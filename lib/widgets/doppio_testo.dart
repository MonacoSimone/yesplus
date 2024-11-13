import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DoppioTesto extends StatelessWidget {
  DoppioTesto(
      {super.key,
      required this.testo1,
      required this.testo2,
      this.weight1 = FontWeight.w600,
      this.color1 = Colors.black,
      this.fontSize1 = 17,
      this.weight2 = FontWeight.w600,
      this.color2 = Colors.black,
      this.fontSize2 = 17});

  String testo1;
  String testo2;
  FontWeight weight1;
  Color color1;
  double fontSize1 = 17;
  FontWeight weight2;
  Color color2;
  double fontSize2 = 17;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: testo1,
          style: TextStyle(
              fontWeight: weight1, color: color1, fontSize: fontSize1),
          children: [
            TextSpan(
                text: testo2,
                style: TextStyle(
                    fontWeight: weight2, color: color2, fontSize: fontSize2))
          ]),
    );
  }
}
