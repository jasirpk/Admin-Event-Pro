import 'dart:io';

import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
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
      // The selected sub-category's picture is an R2 object key, not a URL, so
      // it has to be signed before it can be shown. MediaImage does that and
      // falls back to the placeholder while it resolves or if it fails. The
      // local-file branch below is untouched: a picture the user picks in this
      // form is still a File on disk and never goes near the Media API.
      child: MediaImage(
        imagePath: imagePath,
        placeholder: kMediaPlaceholderImage,
        builder: (context, resolved) => Container(
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
                    image: resolved ?? kMediaPlaceholderImage,
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
      ),
    );
  }
}
