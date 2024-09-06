import 'package:admineventpro/bussiness_layer/repos/delete_showdilog.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/pages/dashboard/edit_vendor.dart';
import 'package:admineventpro/presentation/pages/dashboard/read_vendor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TabBarViewTwo extends StatelessWidget {
  const TabBarViewTwo({
    super.key,
    required this.databaseMethods,
    required this.screenWidth,
    required this.screenHeight,
    required this.uid,
  });

  final DatabaseMethods databaseMethods;
  final double screenWidth;
  final double screenHeight;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final GeneratedVendor generatedVendor = GeneratedVendor();

    return BlocBuilder<GeneratedBloc, GeneratedState>(
      builder: (context, state) {
        return StreamBuilder<QuerySnapshot>(
          stream: generatedVendor.getGeneratedCategoryDetails(uid),
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

            return ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var document = documents[index];
                var data = document.data() as Map<String, dynamic>;
                String imagePath = data['imagePathUrl'];
                String documentId = document.id;

                return FutureBuilder<DocumentSnapshot?>(
                  future:
                      generatedVendor.getCategoryDetailById(uid, documentId),
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
                          'Details not found ',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    var subDetailData =
                        subdetailSnapshot.data!.data() as Map<String, dynamic>;

                    bool isSubmit = subDetailData['isValid'] ?? false;

                    return InkWell(
                      onTap: () {
                        Get.to(() => ReadVendorScreen(
                            vendorName: subDetailData['categoryName'],
                            vendorImage: imagePath,
                            location: subDetailData['location'],
                            description: subDetailData['description'],
                            images: List<Map<String, dynamic>>.from(
                                subDetailData['images']),
                            budget: Map<String, double>.from(
                                subDetailData['budget'])));
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
                              height: screenHeight * 0.17,
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
                                      subDetailData['categoryName'] ??
                                          'No Name',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      subDetailData['description'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: myColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 4.0),
                                        Expanded(
                                          child: Text(
                                            subDetailData['location'] ?? '',
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: screenHeight * 0.014,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        isSubmit
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4, vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: myColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Text(
                                                  'submited',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          screenHeight * 0.010),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PopupMenuButton(
                                  color: Colors.white,
                                  iconColor: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'View Detail') {
                                      Get.to(() => ReadVendorScreen(
                                          vendorName:
                                              subDetailData['categoryName'],
                                          vendorImage: imagePath,
                                          location: subDetailData['location'],
                                          description:
                                              subDetailData['description'],
                                          images:
                                              List<Map<String, dynamic>>.from(
                                                  subDetailData['images']),
                                          budget: Map<String, double>.from(
                                              subDetailData['budget'])));
                                    } else if (value == 'delete') {
                                      showDeleteConfirmationDialog(
                                        uid: uid,
                                        documentId: documentId,
                                        generatedVendor: generatedVendor,
                                      );
                                    } else if (value == 'update') {
                                      Get.to(() => EditVendorScreen(
                                          vendorId: documentId,
                                          vendorName:
                                              subDetailData['categoryName'],
                                          vendorImage: imagePath,
                                          location: subDetailData['location'],
                                          description:
                                              subDetailData['description'],
                                          images:
                                              List<Map<String, dynamic>>.from(
                                                  subDetailData['images']),
                                          budget: Map<String, double>.from(
                                              subDetailData['budget'])));
                                    } else if (value == 'submit') {
                                      await generatedVendor.updateIsValidField(
                                          uid, documentId,
                                          isSumbit: true);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: Text('Delete'),
                                        value: 'delete',
                                      ),
                                      PopupMenuItem(
                                        child: Text('View Detail'),
                                        value: 'View Detail',
                                      ),
                                      PopupMenuItem(
                                        child: Text('Update'),
                                        value: 'update',
                                      ),
                                      PopupMenuItem(
                                        child: Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: myCustomColor,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        value: 'submit',
                                      ),
                                    ];
                                  },
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
            );
          },
        );
      },
    );
  }
}
