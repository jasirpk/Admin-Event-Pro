import 'dart:ui';

import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/sub_category_widget.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_all_templates.dart';
import 'package:admineventpro/presentation/components/ui/custom_text.dart';
import 'package:admineventpro/presentation/pages/dashboard/listof_templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SilverListViewWidget extends StatelessWidget {
  SilverListViewWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  final double screenHeight;
  final double screenWidth;

  final DatabaseMethods databaseMethods = DatabaseMethods();
  final subDatabaseMethods subdatabaseMethods = subDatabaseMethods();

  @override
  Widget build(BuildContext context) {
    String selectedValue = 'Entrepreneur';
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.getVendorDetail(selectedValue),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerAllTemplates(
              screenHeight: screenHeight, screenWidth: screenWidth);
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
        final documents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var data = documents[index].data() as Map<String, dynamic>;
            String imagePath = data['imagePath'];
            String documentId = documents[index].id;

            return FutureBuilder<DocumentSnapshot>(
              future: databaseMethods.getCategoryDetailById(documentId),
              builder: (context, detailSnapshot) {
                if (detailSnapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerAllTemplates(
                      screenHeight: screenHeight, screenWidth: screenWidth);
                }
                if (detailSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${detailSnapshot.error}'),
                  );
                }
                if (!detailSnapshot.hasData || detailSnapshot.data == null) {
                  return Center(child: Text('Details not found'));
                }
                var detailData =
                    detailSnapshot.data!.data() as Map<String, dynamic>;

                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Container(
                      height: screenHeight * 0.32,
                      width: screenWidth * 0.90,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Image(
                                image: imagePath.startsWith('http')
                                    ? NetworkImage(imagePath)
                                    : AssetImage(imagePath) as ImageProvider,
                                fit: BoxFit.cover,
                                height: screenHeight * 0.32,
                                width: screenWidth * 0.90,
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        detailData['categoryName'],
                                        style: TextStyle(
                                          fontSize: detailData['categoryName']
                                                      .length >
                                                  20
                                              ? screenHeight * 0.016
                                              : screenHeight * 0.020,
                                          letterSpacing: 1,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CustomText(
                                        screenHeight: screenHeight,
                                        onpressed: () {
                                          Get.to(
                                            () => SubEventTemplatesScreen(
                                              categoryId: documentId,
                                              categoryName:
                                                  detailData['categoryName'],
                                            ),
                                          );
                                        },
                                        text: 'View All',
                                      ),
                                    ),
                                  ],
                                ),
                                SubCategoryWidget(
                                    subdatabaseMethods: subdatabaseMethods,
                                    documentId: documentId,
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
