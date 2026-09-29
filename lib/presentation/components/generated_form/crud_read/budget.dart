import 'package:flutter/material.dart';

import 'package:admineventpro/presentation/components/media/media_image.dart';

class BudgetWidget extends StatelessWidget {
  const BudgetWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.vendorImage,
    required this.budget,
  });

  final double screenHeight;
  final double screenWidth;
  final String vendorImage;
  final Map<String, double> budget;

  @override
  Widget build(BuildContext context) {
    // The budget card uses the vendor's main picture as its backdrop, so it
    // receives the same imagePathUrl the header does — an R2 object key since
    // the migration. `startsWith('http')` sent that down the AssetImage
    // branch, asking Flutter for a bundled asset named
    // "vendor_images/{uid}/{vendorId}/...jpg", which is the "Unable to load
    // asset" crash. MediaImage signs the key instead, and falls back to the
    // placeholder rather than throwing when it cannot.
    return MediaImage(
      imagePath: vendorImage,
      placeholder: kMediaPlaceholderImage,
      builder: (context, image) => Container(
        height: screenHeight * 0.2,
        width: screenWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.white),
          image: image == null
              ? null
              : DecorationImage(
                  image: image,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6), BlendMode.color)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: screenHeight * 0.1,
            width: screenWidth * 0.25,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                "${budget['from']}\nto\n${budget['to']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
