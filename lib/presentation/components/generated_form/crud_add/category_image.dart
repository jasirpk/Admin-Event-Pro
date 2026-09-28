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

  /// Whether a template supplied a picture to fall back on.
  ///
  /// The standalone flow passes nothing, and the screen normalises a missing
  /// value to the empty string, so both have to count as "no template image".
  bool get hasTemplateImage => (imagePath ?? '').isNotEmpty;

  /// Whether anything at all will be shown — drives the icon, so an empty
  /// slot invites a choice and a filled one offers to change it.
  bool get hasAnyImage => image != null || hasTemplateImage;

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
        imagePath: hasTemplateImage ? imagePath : null,
        placeholder: kMediaPlaceholderImage,
        builder: (context, resolved) => Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
            // A picture the user just chose wins over the template's own.
            // This has to agree with the save path, which uploads the local
            // file whenever there is one — showing the template picture while
            // storing a different image would be a quiet lie.
            image: image != null
                ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
                : hasTemplateImage
                    ? DecorationImage(
                        image: resolved ?? kMediaPlaceholderImage,
                        fit: BoxFit.cover,
                      )
                    : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    hasAnyImage
                        ? Icons.edit
                        : Icons.collections_bookmark,
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
