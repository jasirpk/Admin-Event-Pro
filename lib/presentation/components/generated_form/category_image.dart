import 'dart:io';

import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryImageWidget extends StatelessWidget {
  const CategoryImageWidget({
    super.key,
    required this.imagePath,
    required this.image,
    required this.screenHeight,
  });

  final String? imagePath;
  final File? image;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<GeneratedBloc>().add(PickImage());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          image: imagePath!.isEmpty
              ? (image != null
                  ? DecorationImage(
                      image: FileImage(image!),
                      fit: BoxFit.cover,
                    )
                  : null)
              : DecorationImage(
                  image: imagePath!.startsWith('http')
                      ? NetworkImage(imagePath!)
                      : AssetImage(imagePath!) as ImageProvider,
                  fit: BoxFit.cover,
                ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  image == null && imagePath == null
                      ? Icons.collections_bookmark
                      : Icons.edit,
                  color: Colors.white,
                  size: 40),
            ],
          ),
        ),
        height: screenHeight * 0.2,
      ),
    );
  }
}
