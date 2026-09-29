import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

import 'package:admineventpro/data_layer/models/vendor_document.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';

class componentsWidget extends StatelessWidget {
  const componentsWidget({
    super.key,
    required this.images,
    required this.screenWidth,
  });

  final List<Map<String, dynamic>> images;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        images.length,
        (index) {
          var data = images[index];
          return Container(
            decoration: BoxDecoration(
                color: Colors.white38, borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, color: Colors.white),
                        sizedboxWidth,
                        Text(
                          vendorImageCaption(data),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.038,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reading data['imageUrl'] directly threw on every listing
                  // written since the migration, which stores the key under
                  // 'imagePath' instead — null.startsWith is a crash, not a
                  // missing picture. vendorImageRef accepts either field.
                  MediaImage(
                    imagePath: vendorImageRef(data),
                    placeholder: kMediaPlaceholderImage,
                    builder: (context, image) => CircleAvatar(
                      maxRadius: 14,
                      backgroundColor: Colors.blue,
                      backgroundImage: image,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
