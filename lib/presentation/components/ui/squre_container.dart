import 'package:flutter/material.dart';

class SqureContainerWidget extends StatelessWidget {
  const SqureContainerWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.image,
    required this.text,
  });

  final double screenHeight;
  final double screenWidth;
  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.5),
      ),
      height: screenHeight * 0.12,
      width: screenWidth * 0.30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Image.asset(image), Text(text)],
      ),
    );
  }
}
