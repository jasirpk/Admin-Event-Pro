import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class SearchStackWidget extends StatelessWidget {
  const SearchStackWidget({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          'Search',
          style: TextStyle(
            color: myColor,
            fontFamily: 'JacquesFracois',
            fontSize: screenHeight * (66 / screenHeight),
          ),
        ),
        Positioned(
          left: 60,
          top: 25,
          child: Icon(
            Icons.search,
            size: 80,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
