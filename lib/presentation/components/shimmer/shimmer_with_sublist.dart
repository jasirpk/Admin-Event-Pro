import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:admineventpro/presentation/components/shimmer/skelton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  final List<QueryDocumentSnapshot<Object?>> documents;
  final subDatabaseMethods? subdatabaseMethods;
  final DatabaseMethods? databaseMethods;
  final String categoryId;
  final String subCategoryId;
  final double screenWidth;
  final double screenHeight;

  const ShimmerEffect({
    Key? key,
    required this.documents,
    required this.categoryId,
    required this.subCategoryId,
    required this.screenWidth,
    required this.screenHeight,
    this.subdatabaseMethods,
    this.databaseMethods,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skelton(height: 120, width: 120),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0;
                          i < 4;
                          i++) // Adjust the number of skeletons as needed
                        Column(
                          children: [
                            Skelton(),
                            SizedBox(height: 10),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
