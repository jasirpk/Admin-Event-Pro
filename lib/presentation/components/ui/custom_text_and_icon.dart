import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class CustomTextAndIconWidget extends StatelessWidget {
  CustomTextAndIconWidget({
    required this.screenHeight,
    required this.text,
    required this.icon,
  });

  final double screenHeight;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: myColor,
        ),
        Text(
          text,
          style: TextStyle(
            color: myColor,
            fontFamily: 'JacquesFracois',
            fontSize: screenHeight * 0.020,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
