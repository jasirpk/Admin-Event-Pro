import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/custom_tabbar.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer.dart';

class ReceiptPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final DatabaseMethods databaseMethods = DatabaseMethods();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomTabAppbar(screenHeight: screenHeight),
          body: TabBarView(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: databaseMethods.getVendorDetail(selectedValue),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
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
                      String imagePath = data['imagePath'];
                      String? documentId = document.id;

                      return FutureBuilder<DocumentSnapshot?>(
                        future:
                            databaseMethods.getCategoryDetailById(documentId),
                        builder: (context, subdetailSnapshot) {
                          if (subdetailSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ShimmerEffect(
                              databaseMethods: databaseMethods,
                              documents: documents,
                              categoryId: documentId,
                              subCategoryId: documentId,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            );
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

                          var subDetailData = subdetailSnapshot.data!.data()
                              as Map<String, dynamic>;

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
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
                                      image: imagePath.startsWith('http')
                                          ? NetworkImage(imagePath)
                                          : AssetImage(imagePath)
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subDetailData['categoryName'] ??
                                              'No Name',
                                          style: TextStyle(
                                            fontSize: 18.0,
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
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
              SingleChildScrollView(
                child: Center(
                  child: Text('Hello'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
