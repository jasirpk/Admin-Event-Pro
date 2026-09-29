import 'dart:io';

import 'package:flutter/material.dart';
import 'package:admineventpro/data_layer/models/vendor_document.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';

class ComponentEditsWidget extends StatelessWidget {
  final double screenHeight;
  final int itemCount;
  final List<TextEditingController> imageNameControllers;
  final double screenWidth;
  final List<Map<String, dynamic>> imagesData;

  /// Locally picked replacements, by row index. A row absent from this map
  /// keeps whatever the listing already stores.
  final Map<int, File> replacements;

  /// Asks the screen to pick a replacement for a row.
  final void Function(int index) onPickImage;

  /// Discards a row's pending replacement, restoring the stored image.
  final void Function(int index) onClearReplacement;

  const ComponentEditsWidget({
    Key? key,
    required this.screenHeight,
    required this.itemCount,
    required this.imageNameControllers,
    required this.screenWidth,
    required this.imagesData,
    required this.replacements,
    required this.onPickImage,
    required this.onClearReplacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final entry = imagesData[index];
          final String imageName = vendorImageCaption(entry);
          // Either field: 'imagePath' since the R2 migration, 'imageUrl' on
          // older listings. Reading only 'imageUrl' made every recent listing
          // crash here on `null.startsWith`.
          final String? imageRef = vendorImageRef(entry);
          final File? replacement = replacements[index];

          if (imageNameControllers.length <= index) {
            imageNameControllers.add(TextEditingController(text: imageName));
          }

          return Container(
            width: screenWidth * 0.4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    // The shared bloc's pickedImages list is sized for the add
                    // form (it starts at one slot), so PickImageEvent(index)
                    // threw a RangeError for the second component onwards.
                    // The edit screen holds its own replacements instead.
                    onTap: () => onPickImage(index),
                    child: Stack(
                      children: [
                        MediaImage(
                          // A pending local replacement wins over the stored
                          // image, so the preview matches what Save will write.
                          imagePath: replacement == null ? imageRef : null,
                          placeholder: replacement == null
                              ? kMediaPlaceholderImage
                              : FileImage(replacement) as ImageProvider,
                          builder: (context, image) => Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                                image: image == null
                                    ? null
                                    : DecorationImage(
                                        image: image, fit: BoxFit.cover)),
                            child: Center(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.16,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              // Discards the pending pick rather than the
                              // stored image: removing an existing component
                              // is not something this screen supports, and
                              // silently dropping one on Save would lose it.
                              onPressed: () => onClearReplacement(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: imageNameControllers[index],
                    onChanged: (value) {
                      imagesData[index]['text'] = value;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Image Name',
                      labelStyle: TextStyle(
                        color: Colors.white54,
                      ),
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
