import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Location_widget extends StatelessWidget {
  const Location_widget({
    super.key,
    required this.locationController,
    required this.errorText,
  });

  final TextEditingController locationController;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: locationController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'location',
        errorText: errorText,
        errorStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white70),
        alignLabelWithHint: true,
        suffixIcon: IconButton(
          onPressed: () {
            context.read<GeneratedBloc>().add(FetchLocation());
          },
          icon: Icon(
            Icons.location_on,
            color: Colors.white,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
