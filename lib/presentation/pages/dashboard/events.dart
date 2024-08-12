import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/users/event.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/pages/dashboard/event_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventsListScreen extends StatelessWidget {
  final String userUid;

  const EventsListScreen({super.key, required this.userUid});
  @override
  Widget build(BuildContext context) {
    final entrepreneur = FirebaseAuth.instance.currentUser;
    if (entrepreneur == null) {
      return Center(
        child: Text("User not logged in"),
      );
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    EventMethods eventMethods = EventMethods();
    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Events'),
      body: StreamBuilder<QuerySnapshot?>(
        stream:
            eventMethods.getGeneratedEventsDetails(userUid, entrepreneur.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerAllSubcategories(
                screenHeight: screenHeight, screenWidth: screenWidth);
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading events: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Templates Found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var documents = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var document = documents[index];
                var data = document.data() as Map<String, dynamic>;
                String imagePath = data['imageURL'];
                String documentId = document.id;

                return FutureBuilder<DocumentSnapshot?>(
                  future: eventMethods.getEventsById(userUid, documentId),
                  builder: (context, subdetailSnapshot) {
                    if (subdetailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ShimmerAllSubcategories(
                          screenHeight: screenHeight, screenWidth: screenWidth);
                    }

                    if (subdetailSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading details: ${subdetailSnapshot.error}',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (!subdetailSnapshot.hasData ||
                        subdetailSnapshot.data == null ||
                        subdetailSnapshot.data!.data() == null) {
                      return Center(
                        child: Text(
                          'Details not found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    var subDetailData =
                        subdetailSnapshot.data!.data() as Map<String, dynamic>;

                    return InkWell(
                      onTap: () {
                        Get.to(() => EventDetailScreen(
                            clientName: subDetailData['clientName'],
                            clientEmail: subDetailData['email'],
                            phoneNumber: subDetailData['phoneNumber'],
                            location: subDetailData['location'],
                            eventType: subDetailData['eventype'],
                            description: subDetailData['eventAbout'],
                            imagePath: imagePath,
                            guests: subDetailData['guestCount'],
                            amount: subDetailData['sum'],
                            date: subDetailData['date'],
                            time: subDetailData['time'],
                            selectedVendors: List<Map<String, dynamic>>.from(
                                subDetailData['selectedVendors'])));
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
                              height: screenHeight * 0.16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imagePath.startsWith('http')
                                    ? FadeInImage.assetNetwork(
                                        placeholder: Assigns.placeHolderImage,
                                        image: imagePath,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        imagePath,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subDetailData['eventype'] ?? 'No Name',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          subDetailData['date'] ?? '',
                                          style: TextStyle(
                                              fontSize: 14.0, letterSpacing: 2),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          subDetailData['time'] ?? '',
                                          style: TextStyle(
                                              letterSpacing: 2,
                                              fontSize: screenHeight * 0.014,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: myColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Text(
                                        'Accepted',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: screenHeight * 0.010),
                                      ),
                                    )
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
                                      Get.to(() => EventDetailScreen(
                                          clientName:
                                              subDetailData['clientName'],
                                          clientEmail: subDetailData['email'],
                                          phoneNumber:
                                              subDetailData['phoneNumber'],
                                          location: subDetailData['location'],
                                          eventType: subDetailData['eventype'],
                                          description:
                                              subDetailData['eventAbout'],
                                          imagePath: imagePath,
                                          guests: subDetailData['guestCount'],
                                          amount: subDetailData['sum'],
                                          date: subDetailData['date'],
                                          time: subDetailData['time'],
                                          selectedVendors:
                                              List<Map<String, dynamic>>.from(
                                                  subDetailData[
                                                      'selectedVendors'])));
                                    } else if (value == 'Accept') {
                                      // await generatedVendor.updateIsValidField(uid, documentId, isSumbit: true);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: Text('View Detail'),
                                        value: 'View Detail',
                                      ),
                                      PopupMenuItem(
                                        child: Text(
                                          'Accept',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2CBB5D),
                                          ),
                                        ),
                                        value: 'Accept',
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
            ),
          );
        },
      ),
    );
  }
}
