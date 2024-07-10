import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/pages/dashboard/add_vendors.dart';
import 'package:admineventpro/common/style.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final subDatabaseMethods subCategoryMethods = subDatabaseMethods();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBarWithDivider(title: 'Favorites'),
        body: Center(
          child: Text(
            'User is not authenticated',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Favorites'),
      body: StreamBuilder<QuerySnapshot>(
        stream: subCategoryMethods.getFavoriteSubcategories(user.uid),
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
                'No favorites',
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
              var data = document.data() as Map<String, dynamic>?;

              if (data == null) {
                // Log the issue for debugging purposes
                print(
                    'No data found for document at index $index with ID ${document.id}');
                return SizedBox.shrink(); // Skip this item
              }

              String subimagePath = data['imagePath'];
              String subCategoryId = document.id;

              return FutureBuilder<DocumentSnapshot>(
                future: subCategoryMethods.getFavoritesById(
                  user.uid,
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
                    print('Details not found for subCategoryId $subCategoryId');
                    return Center(
                      child: Text(
                        'Details not found for $subCategoryId',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  var subDetailData =
                      subdetailSnapshot.data!.data() as Map<String, dynamic>?;
                  if (subDetailData == null) {
                    print(
                        'No detail data found for subCategoryId $subCategoryId');
                    return SizedBox.shrink(); // Skip this item
                  }

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
                                      try {
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null) {
                                          await subCategoryMethods
                                              .toggleFavoriteStatus(
                                                  user.uid,
                                                  subCategoryName,
                                                  about,
                                                  imagePath,
                                                  id,
                                                  isFavorite);
                                          print(
                                              'Favorite status updated successfully');
                                        } else {
                                          print('User not authenticated');
                                          showCustomSnackBar("Error",
                                              "User is not authenticated");
                                        }
                                      } catch (e) {
                                        showCustomSnackBar("Error",
                                            "Failed to update favorite status: $e");
                                        print(
                                            'Failed to update favorite status: $e');
                                      }
                                    },
                                    icon: Icon(isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border),
                                    color: isFavorite ? myColor : Colors.white,
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
