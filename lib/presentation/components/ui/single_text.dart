import 'package:flutter/material.dart';

class SingleTextWidget extends StatelessWidget {
  const SingleTextWidget({
    super.key,
    required this.screenHeight,
    required this.text,
  });

  final double screenHeight;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
          fontSize: screenHeight * (16 / screenHeight),
          fontWeight: FontWeight.w400,
          letterSpacing: 1),
    );
  }
}
