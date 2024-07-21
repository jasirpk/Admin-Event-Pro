import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final int? maxLine;
  final String? labelText;
  final VoidCallback? onTap;
  final TextInputType keyboardtype;
  final bool readOnly;
  final IconData? prefixIcon;
  const CustomTextFieldWidget(
      {super.key,
      this.controller,
      this.maxLine,
      this.labelText,
      required this.keyboardtype,
      this.onTap,
      required this.readOnly,
      this.prefixIcon});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLine,
      keyboardType: keyboardtype,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white54,
        ),
        alignLabelWithHint: true,
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
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }
}
