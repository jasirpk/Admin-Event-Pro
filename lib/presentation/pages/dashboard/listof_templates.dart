import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/sub_category.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubEventTemplatesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubEventTemplatesScreen(
      {super.key, required this.categoryId, required this.categoryName});
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
          sizedboxWidth
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: subdatabaseMethods.getSubcategories(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
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
                    categoryId, subCategoryId),
                builder: (context, subdetailSnapshot) {
                  if (subdetailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerEffect(
                        documents: documents,
                        subdatabaseMethods: subdatabaseMethods,
                        categoryId: categoryId,
                        subCategoryId: subCategoryId,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight);
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
                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white38,
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
                            children: [
                              Text(
                                subDetailData['subCategoryName'] ?? 'No Name',
                                style: TextStyle(
                                  fontSize: 18.0,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.favorite_border),
                              color: Colors.grey,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.forward),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
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
