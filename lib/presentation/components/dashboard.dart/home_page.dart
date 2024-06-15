import 'package:admineventpro/presentation/components/ui/silver_appbar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SilverAppBarWidget(screenHeight: MediaQuery.of(context).size.height),
        // Add more widgets here for HomePage
      ],
    );
  }
}
