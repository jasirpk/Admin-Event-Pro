import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class RichTextWidget extends StatelessWidget {
  const RichTextWidget({
    super.key,
    required this.screenHeight,
    this.text,
    required this.headline,
  });

  final double screenHeight;
  final String? text;
  final String headline;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: '• ',
          style: myTextStyle(screenHeight * 0.018, myColor),
          children: [
            TextSpan(text: headline),
            TextSpan(text: ' '),
            TextSpan(text: text, style: TextStyle(color: Colors.white))
          ]),
    );
  }
}
