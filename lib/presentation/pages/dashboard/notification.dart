import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/users/users_profile.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/pages/dashboard/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final EventUsersProfile eventUsersProfile = EventUsersProfile();

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: Assigns.notification),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventUsersProfile.getUserProfile(),
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Templates Found'),
            );
          }
          final documents = snapshot.data!.docs;

          return GridView.builder(
            itemCount: documents.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 80,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
            itemBuilder: (context, index) {
              var data = documents[index];
              var profileImage = data['imagePath'];
              var userUid = documents[index].id;

              // Check if the document is new (added within the last 24 hours)
              var timestamp = data['timestamp'] as Timestamp;
              bool isNew = timestamp.toDate().isAfter(
                    DateTime.now().subtract(Duration(hours: 24)),
                  );

              return FutureBuilder<DocumentSnapshot>(
                future: eventUsersProfile.getUserDetailById(userUid),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ShimmerSubCategoryItem(
                        screenHeight: screenHeight, screenWidth: screenWidth);
                  }
                  if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${detailSnapshot.error}'),
                    );
                  }
                  if (!detailSnapshot.hasData || detailSnapshot.data == null) {
                    return Center(child: Text('Details not found'));
                  }
                  return InkWell(
                    onTap: () {
                      Get.to(() => EventsListScreen(userUid: userUid));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Container(
                        color: Colors.white24,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : AssetImage(Assigns.personImage)
                                        as ImageProvider,
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: data['userName'],
                                  style:
                                      TextStyle(fontSize: screenHeight * 0.018),
                                  children: [
                                    TextSpan(text: ' '),
                                    TextSpan(
                                      text: 'recently added a new profile',
                                      style: TextStyle(
                                          fontSize: screenHeight * 0.014,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                data['email'],
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  Get.to(
                                      () => EventsListScreen(userUid: userUid));
                                },
                                icon: Icon(
                                  CupertinoIcons.forward,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isNew)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: myColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenHeight * 0.012),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
