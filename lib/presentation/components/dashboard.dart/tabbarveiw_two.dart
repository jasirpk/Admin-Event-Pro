import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/popupmenu_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabBarViewTwo extends StatelessWidget {
  const TabBarViewTwo({
    super.key,
    required this.databaseMethods,
    required this.screenWidth,
    required this.screenHeight,
  });

  final DatabaseMethods databaseMethods;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: databaseMethods.getVendorDetail(Assigns.selectedValue),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Center(
        //     child: CircularProgressIndicator(),
        //   );
        // }

        // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        //   return Center(
        //     child: Text(
        //       'No Templates Found for ',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //   );
        // }

        var documents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: 2,
          itemBuilder: (context, index) {
            var document = documents[index];
            // var data = document.data() as Map<String, dynamic>;
            // String imagePath = data['imagePath'];
            String? documentId = document.id;

            return FutureBuilder<DocumentSnapshot?>(
              future: databaseMethods.getCategoryDetailById(documentId),
              builder: (context, subdetailSnapshot) {
                // if (subdetailSnapshot.connectionState ==
                //     ConnectionState.waiting) {
                //   return ShimmerEffect(
                //     databaseMethods: databaseMethods,
                //     documents: documents,
                //     categoryId: documentId,
                //     subCategoryId: documentId,
                //     screenWidth: screenWidth,
                //     screenHeight: screenHeight,
                //   );
                // }

                // if (!subdetailSnapshot.hasData ||
                //     subdetailSnapshot.data == null ||
                //     subdetailSnapshot.data!.data() == null) {
                //   return Center(
                //     child: Text(
                //       'Details not found for $documentId',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   );
                // }

                // var subDetailData = subdetailSnapshot.data!.data()
                //     as Map<String, dynamic>;

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
                              Text(''
                                  // subDetailData['categoryName'] ??
                                  //     'No Name',
                                  // style: TextStyle(
                                  //   fontSize: 18.0,
                                  //   fontWeight: FontWeight.bold,
                                  // ),
                                  ),
                              SizedBox(height: 4.0),
                              Text(''
                                  // subDetailData['description'] ?? '',
                                  // overflow: TextOverflow.ellipsis,
                                  // maxLines: 4,
                                  // style: TextStyle(fontSize: 14.0),
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
                            icon: Icon(Icons.favorite_border),
                            color: Colors.grey,
                          ),
                          PopubMenuButton(),
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
    );
  }
}
