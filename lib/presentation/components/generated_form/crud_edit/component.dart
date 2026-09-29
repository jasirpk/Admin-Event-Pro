import 'package:flutter/material.dart';

import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:admineventpro/presentation/pages/dashboard/edit_vendor.dart';

/// The Essential Components editor.
///
/// Renders one tile per [ComponentRow]. A row may hold a stored R2 key, a
/// freshly picked local file, or neither (a row just added). The picked file
/// wins, so the preview always matches what Save will write.
class ComponentEditsWidget extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final List<ComponentRow> rows;
  final void Function(int index) onPickImage;
  final void Function(int index) onRemoveRow;

  const ComponentEditsWidget({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
    required this.rows,
    required this.onPickImage,
    required this.onRemoveRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        height: screenHeight * 0.3,
        alignment: Alignment.center,
        child: Text(
          'No components yet — use + to add one.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      height: screenHeight * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          final picked = row.picked;

          return Container(
            width: screenWidth * 0.4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => onPickImage(index),
                    child: Stack(
                      children: [
                        MediaImage(
                          // A stored key is resolved through the media API; a
                          // local pick needs no resolving and takes priority.
                          imagePath: picked == null ? row.existingRef : null,
                          placeholder: picked == null
                              ? kMediaPlaceholderImage
                              : FileImage(picked) as ImageProvider,
                          builder: (context, image) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                              image: image == null
                                  ? null
                                  : DecorationImage(
                                      image: image, fit: BoxFit.cover),
                            ),
                            child: Center(
                              child: Icon(
                                row.hasImage ? Icons.edit : Icons.add_a_photo,
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
                              tooltip: 'Remove this component',
                              icon: Icon(Icons.close, color: Colors.white),
                              // Drops the row from what Save writes. The
                              // stored object itself is left in R2 — see
                              // EditVendorScreen._removeRow.
                              onPressed: () => onRemoveRow(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: row.caption,
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
                      labelStyle: TextStyle(color: Colors.white54),
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
