import 'dart:io';

import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';

class UserProfileImageWidget extends StatelessWidget {
  const UserProfileImageWidget({
    super.key,
    required this.image,
    required this.screenWidth,
    required this.screenHeight,
    required this.profileImage,
    required this.onTap,
  });

  /// A freshly picked avatar, not yet uploaded.
  final File? image;
  final double screenWidth;
  final double screenHeight;

  /// The stored avatar: an R2 object key, or a legacy URL on an older profile.
  final String profileImage;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // The stored avatar is an R2 object key since the migration, so it has
      // to be signed before it can be shown. NetworkImage was given the raw
      // key and simply failed. A freshly picked file needs no resolving and
      // takes priority, so the preview always matches what Save will store.
      child: MediaImage(
        imagePath: image == null ? profileImage : null,
        placeholder: image == null ? null : FileImage(image!) as ImageProvider,
        builder: (context, resolved) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey,
            image: resolved == null
                ? null
                : DecorationImage(image: resolved, fit: BoxFit.cover),
          ),
          child: Center(
            child: Icon(
              resolved == null ? Icons.collections_bookmark : Icons.edit,
              color: Colors.white,
              size: 30,
            ),
          ),
          width: screenWidth * 0.4,
          height: screenHeight * 0.16,
        ),
      ),
    );
  }
}
