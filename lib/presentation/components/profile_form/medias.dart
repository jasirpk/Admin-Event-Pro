import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';

/// The portfolio editor.
///
/// One tile per [PortfolioRow]. A row holds either an image the profile
/// already stores, one the user just picked, or neither (a row just added).
/// A picked file wins, so the preview matches what Save will write.
class MediasWidget extends StatelessWidget {
  const MediasWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.portfolio,
    required this.onPickImage,
    required this.onRemoveRow,
  });

  final double screenHeight;
  final double screenWidth;
  final List<PortfolioRow> portfolio;
  final void Function(int index) onPickImage;
  final void Function(int index) onRemoveRow;

  @override
  Widget build(BuildContext context) {
    if (portfolio.isEmpty) {
      return Container(
        height: screenHeight * 0.2,
        alignment: Alignment.center,
        child: Text(
          'No portfolio images yet — use + to add one.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      height: screenHeight * 0.2,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: portfolio.length,
        itemBuilder: (context, index) {
          final row = portfolio[index];
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
                        // A stored key is resolved through the media API; a
                        // local pick needs no resolving and takes priority.
                        MediaImage(
                          imagePath: picked == null ? row.existingRef : null,
                          placeholder: picked == null
                              ? null
                              : FileImage(picked) as ImageProvider,
                          builder: (context, resolved) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                              image: resolved == null
                                  ? null
                                  : DecorationImage(
                                      image: resolved, fit: BoxFit.cover),
                            ),
                            child: Center(
                              child: Icon(
                                row.hasImage
                                    ? Icons.edit
                                    : Icons.collections_bookmark,
                                color: Colors.white,
                                size: 30,
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
                              tooltip: 'Remove this image',
                              icon: Icon(Icons.close, color: Colors.white),
                              // Drops the row from what Save writes. The
                              // stored object is left in R2 — see
                              // ProfileScreen._removePortfolioRow.
                              onPressed: () => onRemoveRow(index),
                            ),
                          ),
                        ),
                      ],
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
