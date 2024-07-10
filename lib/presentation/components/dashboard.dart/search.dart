import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/category.dart';

import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/pages/dashboard/listof_templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController searchController = TextEditingController();

  Stream<QuerySnapshot>? searchResults;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Icon(
          CupertinoIcons.back,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    Text(
                      'Search',
                      style: TextStyle(
                          color: myColor,
                          fontFamily: 'JacquesFracois',
                          fontSize: screenHeight * (66 / screenHeight)),
                    ),
                    Positioned(
                      left: 60,
                      top: 25,
                      child: Icon(
                        Icons.search,
                        size: 80,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(18.0),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search',
                      labelStyle: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Top Popular Templates'),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      databaseMethods.getVendorDetail(Assigns.selectedValue),
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
                            future: databaseMethods
                                .getCategoryDetailById(documentId),
                            builder: (context, subdetailSnapshot) {
                              if (subdetailSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ShimmerAllSubcategories(
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth);
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

                              return InkWell(
                                onTap: () {
                                  Get.to(() => SubEventTemplatesScreen(
                                      categoryId: documentId,
                                      categoryName:
                                          subDetailData['categoryName']));
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.30,
                                        height: screenHeight * 0.15,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                subDetailData['description'] ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 4,
                                                style:
                                                    TextStyle(fontSize: 14.0),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
