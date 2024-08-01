import 'package:admineventpro/presentation/components/privacy_policy/rich_text.dart';
import 'package:flutter/material.dart';

class privacyBullets extends StatelessWidget {
  const privacyBullets({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichTextWidget(screenHeight: screenHeight, headline: 'Email address'),
          SizedBox(height: 10),
          RichTextWidget(
              screenHeight: screenHeight, headline: 'First name and last name'),
          SizedBox(height: 10),
          RichTextWidget(screenHeight: screenHeight, headline: 'Phone number'),
          SizedBox(height: 10),
          RichTextWidget(screenHeight: screenHeight, headline: 'Usage Data'),
        ],
      ),
    );
  }
}
