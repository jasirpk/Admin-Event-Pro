import 'package:flutter/material.dart';

class Description_Widget extends StatelessWidget {
  const Description_Widget({
    super.key,
    required this.descriptionEditingController,
  });

  final TextEditingController descriptionEditingController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: descriptionEditingController,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: TextStyle(color: Colors.white70),
        alignLabelWithHint: true,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      maxLines: 4,
    );
  }
}
