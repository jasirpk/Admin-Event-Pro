import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/pages/dashboard/listof_templates.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({
    super.key,
    required this.databaseMethods,
    required this.screenHeight,
    required this.screenWidth,
  });

  final DatabaseMethods databaseMethods;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.getVendorDetail(Assigns.selectedValue),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerAllSubcategories(
              screenHeight: screenHeight, screenWidth: screenWidth);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No Templates Found for ',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var documents = snapshot.data!.docs;

        return Container(
          height: screenHeight * 0.6,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var data = document.data() as Map<String, dynamic>;
              String imagePath = data['imagePath'];
              String? documentId = document.id;

              return FutureBuilder<DocumentSnapshot?>(
                future: databaseMethods.getCategoryDetailById(documentId),
                builder: (context, subdetailSnapshot) {
                  if (subdetailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerAllSubcategories(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  }

                  if (!subdetailSnapshot.hasData ||
                      subdetailSnapshot.data == null ||
                      subdetailSnapshot.data!.data() == null) {
                    return Center(
                      child: Text(
                        'Details not found for $documentId',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  var subDetailData =
                      subdetailSnapshot.data!.data() as Map<String, dynamic>;

                  return InkWell(
                    onTap: () {
                      Get.to(() => SubEventTemplatesScreen(
                          categoryId: documentId,
                          categoryName: subDetailData['categoryName']));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth * 0.30,
                            height: screenHeight * 0.16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imagePath,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              fit: BoxFit.cover,
                              width: screenWidth * 0.30,
                              height: screenHeight * 0.16,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subDetailData['categoryName'] ?? 'No Name',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    subDetailData['description'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'JacquesFracois',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(CupertinoIcons.forward),
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
