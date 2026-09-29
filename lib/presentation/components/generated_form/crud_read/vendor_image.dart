import 'package:flutter/material.dart';

import 'package:admineventpro/presentation/components/media/media_image.dart';

class VendorImageWidget extends StatelessWidget {
  const VendorImageWidget({
    super.key,
    required this.vendorImage,
  });

  final String vendorImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      // The vendor's main image is an R2 object key since the migration, so
      // it needs signing. `startsWith('http')` used to decide, which sent
      // every key down the AssetImage branch and asked Flutter to load a
      // bundled asset that does not exist.
      child: MediaImage(
        imagePath: vendorImage,
        placeholder: kMediaPlaceholderImage,
        builder: (context, image) => CircleAvatar(
          backgroundImage: image,
          maxRadius: 60,
        ),
      ),
    );
  }
}
