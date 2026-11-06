import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_carousal.dart';
import 'package:admineventpro/presentation/pages/dashboard/listof_templates.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admineventpro/presentation/components/media/media_image.dart';

class ListViewWidget extends StatelessWidget {
  const ListViewWidget({
    super.key,
    required this.databaseMethods,
    required this.selectedValue,
    required this.screenHeight,
    required this.screenWidth,
  });

  final DatabaseMethods databaseMethods;
  final String selectedValue;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.getVendorDetail(selectedValue),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerCarousal();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No Templates Found'),
          );
        }
        var documents = snapshot.data!.docs;

        return ConstrainedBox(
          constraints: BoxConstraints.expand(height: 120),
          child: CarouselSlider.builder(
            itemCount: documents.length,
            itemBuilder: (context, index, pageIndex) {
              var data = documents[index].data() as Map<String, dynamic>;
              // Kept nullable: an absent imagePath means "no artwork recorded",
              // which _CategoryThumbnail renders directly. Defaulting it to the
              // bundled placeholder used to push an asset path into a URL-only
              // resolver, which can never produce one.
              String? imagePath = (data['imagePath'] as String?)?.trim();
              String documentId = documents[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: databaseMethods.getCategoryDetailById(documentId),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerCarousal();
                  }
                  if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${detailSnapshot.error}'),
                    );
                  }
                  if (!detailSnapshot.hasData) {
                    return Center(
                      child: Text('Details Not Found'),
                    );
                  }
                  var detailData = detailSnapshot.data!.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      Get.to(() => SubEventTemplatesScreen(categoryId: documentId, categoryName: detailData['categoryName']));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          _CategoryThumbnail(
                            imagePath: imagePath,
                            width: screenWidth,
                            height: screenHeight,
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                ),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              width: screenWidth * 0.4,
                              padding: EdgeInsets.only(left: 8, top: 8),
                              child: Text(
                                detailData['categoryName'] ?? 'No name',
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.016,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              reverse: false,
              viewportFraction: 0.48,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayInterval: Duration(seconds: 6),
              autoPlayAnimationDuration: Duration(seconds: 3),
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
          ),
        );
      },
    );
  }
}

/// The artwork for one Popular Categories tile.
///
/// A Firestore `imagePath` is one of three things, and only the last needs the
/// network: absent, a bundled asset, or an R2 objectKey that must be signed.
/// Routing the first two through [MediaUrl] yielded a null URL, which reached
/// `CachedNetworkImage` as the empty string and drew the error state over
/// artwork that was never actually missing.
class _CategoryThumbnail extends StatelessWidget {
  const _CategoryThumbnail({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  final String? imagePath;
  final double width;
  final double height;

  /// Grey tile with a spinner: the objectKey is still being signed.
  Widget _loading(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );

  /// Grey tile with the placeholder and an error badge: signing or the fetch
  /// genuinely failed.
  Widget _failed(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(image: AssetImage(kMediaPlaceholderAsset), fit: BoxFit.cover)),
        child: Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      );

  /// A bundled image, with no error badge — nothing has gone wrong here.
  Widget _asset(String assetPath) => Image.asset(
        assetPath,
        fit: BoxFit.cover,
        width: width,
        height: height,
      );

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    if (path == null || path.isEmpty) return _asset(kMediaPlaceholderAsset);
    if (path.startsWith('assets/')) return _asset(path);

    return MediaUrl(
      imagePath: path,
      loadingBuilder: _loading,
      errorBuilder: _failed,
      builder: (context, url) => url == null
          ? _failed(context)
          : CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, _) => _loading(context),
              errorWidget: (context, _, __) => _failed(context),
              fit: BoxFit.cover,
              width: width,
              height: height,
            ),
    );
  }
}
