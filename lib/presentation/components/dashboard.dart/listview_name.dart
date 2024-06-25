import 'package:admineventpro/data_layer/services/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListViewName extends StatelessWidget {
  const ListViewName({
    super.key,
    required this.databaseMethods,
    required this.selectedValue,
  });

  final DatabaseMethods databaseMethods;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<QuerySnapshot>(
        stream: databaseMethods.getVendorDetail(selectedValue),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final documents = snapshot.data!.docs;
          return Padding(
            padding: EdgeInsets.only(top: 12, bottom: 14),
            child: SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: documents.length + 1, // Add 1 for the "All" item
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          'All',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  } else {
                    String documentId = documents[index - 1].id; // Adjust index
                    return FutureBuilder<DocumentSnapshot>(
                      future: databaseMethods.getCategoryDetailById(documentId),
                      builder: (context, detailSnapshot) {
                        if (detailSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (detailSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${detailSnapshot.error}'),
                          );
                        }
                        var detailData =
                            detailSnapshot.data!.data() as Map<String, dynamic>;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              detailData['categoryName'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
