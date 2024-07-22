import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class RevenuesWidget extends StatelessWidget {
  const RevenuesWidget({
    super.key,
    required this.data,
    required this.text,
    required this.value,
  });

  final Map<String, dynamic> data;
  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text),
        sizedboxWidth,
        Text(
          value,
          style: TextStyle(color: myColor),
        ),
      ],
    );
  }
}
