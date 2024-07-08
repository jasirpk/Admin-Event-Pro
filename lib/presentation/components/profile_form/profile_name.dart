import 'dart:io';

import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileNameWidget extends StatelessWidget {
  const UserProfileNameWidget({
    super.key,
    required this.image,
    required this.screenWidth,
    required this.screenHeight,
  });

  final File? image;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ProfileBloc>().add(PickImage());
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey,
            image: image != null
                ? DecorationImage(
                    image: FileImage(image!),
                    fit: BoxFit.cover,
                  )
                : null),
        child: Center(
          child: Icon(
            image == null ? Icons.collections_bookmark : Icons.edit,
            color: Colors.white,
            size: 30,
          ),
        ),
        width: screenWidth * 0.4,
        height: screenHeight * 0.16,
      ),
    );
  }
}
