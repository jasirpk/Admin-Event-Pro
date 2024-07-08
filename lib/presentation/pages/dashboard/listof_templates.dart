import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/pages/dashboard/add_vendors.dart';
import 'package:admineventpro/common/style.dart';

class SubEventTemplatesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubEventTemplatesScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subDatabaseMethods subdatabaseMethods = subDatabaseMethods();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: categoryName,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {},
          ),
          sizedboxWidth,
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: myColor,
              height: 27,
              width: 27,
            ),
          ),
          sizedboxWidth,
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: subdatabaseMethods.getSubcategories(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerAllSubcategories(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Templates Found for $categoryId',
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
              String subimagePath = data['imagePath'];
              String subCategoryId = document.id;

              return FutureBuilder<DocumentSnapshot>(
                future: subdatabaseMethods.getSubCategoryId(
                  categoryId,
                  subCategoryId,
                ),
                builder: (context, subdetailSnapshot) {
                  if (subdetailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerAllSubcategories(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    );
                  }

                  if (!subdetailSnapshot.hasData ||
                      subdetailSnapshot.data == null ||
                      subdetailSnapshot.data!.data() == null) {
                    return Center(
                      child: Text(
                        'Details not found for $subCategoryId',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  var subDetailData =
                      subdetailSnapshot.data!.data() as Map<String, dynamic>;
                  bool isFavorite = subDetailData['isFavorite'] ?? false;

                  return InkWell(
                    onTap: () {
                      Get.to(() => AddVendorsScreen(
                            categoryName: subDetailData['subCategoryName'],
                            categoryDescription: subDetailData['about'],
                            imagePath: subimagePath,
                          ));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
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
                            height: screenHeight * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: subimagePath.startsWith('http')
                                    ? NetworkImage(subimagePath)
                                    : AssetImage(subimagePath) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  subDetailData['subCategoryName'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: subDetailData['subCategoryName']
                                                .length >
                                            14
                                        ? 16
                                        : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  subDetailData['about'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                          BlocBuilder<DashboardBloc, DashboardState>(
                            builder: (context, state) {
                              if (state is DashboardLoading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is DashboardError) {
                                return Center(
                                  child: Text('Error: ${state.errorMessage}'),
                                );
                              }

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      String id = subCategoryId;
                                      String imagePath =
                                          subDetailData['imagePath'];
                                      String subCategoryName =
                                          subDetailData['subCategoryName'];
                                      String about = subDetailData['about'];
                                      // await subdatabaseMethods
                                      //     .updateIsValidField(
                                      //         categoryId, subCategoryId,
                                      //         isSumbit: true);
                                      try {
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null) {
                                          await subDatabaseMethods()
                                              .toggleFavoriteStatus(
                                                  user.uid,
                                                  subCategoryName,
                                                  about,
                                                  imagePath,
                                                  id,
                                                  true);
                                          print(
                                              'Data added'); // Show success message
                                          showCustomSnackBar("Success",
                                              "Details Added Successfully");
                                        } else {
                                          print(
                                              'data not added'); // Show error message if user is not authenticated
                                          showCustomSnackBar("Error",
                                              "User is not authenticated");
                                        }
                                      } catch (e) {
                                        // Show error message if there's an exception
                                        showCustomSnackBar("Error",
                                            "Failed to add vendor details: $e");
                                        print(
                                            'Failed to add vendor details: $e');
                                      }
                                    },
                                    icon: Icon(Icons.favorite_border
                                        // isFavorite
                                        //     ? Icons.favorite
                                        //     : Icons.favorite_border,
                                        ),
                                    color: Colors.white,
                                  ),
                                  IconButton(
                                    onPressed: () async {},
                                    icon: Icon(CupertinoIcons.forward),
                                    color: Colors.white,
                                  ),
                                ],
                              );
                            },
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
      ),
    );
  }
}
