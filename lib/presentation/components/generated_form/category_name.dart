import 'package:flutter/material.dart';

class CategoryNameWidget extends StatelessWidget {
  const CategoryNameWidget({
    super.key,
    required this.nameEditingController,
  });

  final TextEditingController nameEditingController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nameEditingController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white), // Customize border color and width
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white), // Customize focused border color and width
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: 'Displayed Name',
        labelStyle: TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }
}
