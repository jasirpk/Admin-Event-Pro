import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';
import 'package:pushable_button/pushable_button.dart';

class PushableButton_widget extends StatelessWidget {
  final String buttonText;
  final VoidCallback onpressed;

  const PushableButton_widget({
    super.key,
    required this.buttonText,
    required this.onpressed,
  });
  @override
  Widget build(BuildContext context) {
    return PushableButton(
      elevation: 8,
      hslColor: HSLColor.fromColor(myColor),
      height: 50,
      shadow: BoxShadow(),
      onPressed: onpressed,
      child: Text(
        buttonText,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
