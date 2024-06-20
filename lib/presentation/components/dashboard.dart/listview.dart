import 'package:admineventpro/data_layer/services/database.dart';
import 'package:admineventpro/presentation/components/ui/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListViewWidget extends StatelessWidget {
  const ListViewWidget({
    super.key,
    required this.databaseMethods,
    required this.selectedValue,
    required this.screenHeight,
  });

  final DatabaseMethods databaseMethods;
  final String selectedValue;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<QuerySnapshot>(
        stream: databaseMethods.getVendorDetail(selectedValue),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerList();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Templates Found'),
            );
          }
          var documents = snapshot.data!.docs;

          return Container(
            height: 120,
            child: CarouselSlider.builder(
              itemCount: documents.length,
              itemBuilder: (context, index, pageIndex) {
                var data = documents[index].data() as Map<String, dynamic>;
                String imagePath = data['imagePath'] ??
                    'assets/images/venue_decoration_img.jpg';
                String documentId = documents[index].id;

                return FutureBuilder<DocumentSnapshot>(
                  future: databaseMethods.getCategoryDetailById(documentId),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ShimmerList();
                    }
                    if (detailSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${detailSnapshot.error}'),
                      );
                    }
                    if (!detailSnapshot.hasData) {
                      return Center(
                        child: Text('Details Not Found'),
                      );
                    }
                    var detailData =
                        detailSnapshot.data!.data() as Map<String, dynamic>;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imagePath.startsWith('http')
                              ? NetworkImage(imagePath)
                              : AssetImage(imagePath) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        color: Colors.grey,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8, top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                detailData['categoryName'] ?? 'No name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.020,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                reverse: false,
                viewportFraction: 0.48,
                autoPlayCurve: Curves.fastOutSlowIn,
                // autoPlay: true,
                autoPlayInterval: Duration(seconds: 6),
                autoPlayAnimationDuration: Duration(seconds: 3),
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
          );
        },
      ),
    );
  }
}
