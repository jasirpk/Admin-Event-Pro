import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class CustomTextWithIconsWidget extends StatelessWidget {
  const CustomTextWithIconsWidget({
    super.key,
    required this.screenHeight,
    required this.text,
    required this.onAddpressed,
    required this.onRemovePressed,
  });

  final double screenHeight;
  final String text;
  final VoidCallback onAddpressed;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: myColor,
              fontFamily: 'JacquesFracois',
              fontSize: screenHeight * 0.020,
              fontWeight: FontWeight.w400,
              letterSpacing: 1),
        ),
        Container(
          child: Row(
            children: [
              IconButton(
                  onPressed: onAddpressed,
                  icon: Icon(Icons.add, size: 30, color: myColor)),
              SizedBox(
                width: 8,
              ),
              IconButton(
                  onPressed: onRemovePressed,
                  icon: Icon(Icons.remove, size: 30, color: myColor)),
            ],
          ),
        ),
      ],
    );
  }
}
