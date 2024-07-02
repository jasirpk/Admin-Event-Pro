import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_carousal.dart';
import 'package:admineventpro/presentation/pages/dashboard/listof_templates.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              String imagePath =
                  data['imagePath'] ?? 'assets/images/venue_decoration_img.jpg';
              String documentId = documents[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: databaseMethods.getCategoryDetailById(documentId),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState ==
                      ConnectionState.waiting) {
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
                  var detailData =
                      detailSnapshot.data!.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      Get.to(() => SubEventTemplatesScreen(
                          categoryId: documentId,
                          categoryName: detailData['categoryName']));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imagePath.startsWith('http')
                              ? NetworkImage(imagePath)
                              : AssetImage(imagePath) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
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
