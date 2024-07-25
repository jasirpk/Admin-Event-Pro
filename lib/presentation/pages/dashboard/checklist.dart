import 'package:admineventpro/bussiness_layer/repos/call_launcher.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/users/users_profile.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/pages/dashboard/events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final EventUsersProfile eventUsersProfile = EventUsersProfile();

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'CheckList'),
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
                var phoneNumber = data['phoneNumber'];
                var userUid = documents[index].id;
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
                    if (!detailSnapshot.hasData ||
                        detailSnapshot.data == null) {
                      return Center(child: Text('Details not found'));
                    }
                    return InkWell(
                      onTap: () {
                        Get.to(() => EventsListScreen(userUid: userUid));
                      },
                      child: Card(
                        color: Colors.white24,
                        child: Container(
                          width: double.infinity,
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : AssetImage(Assigns.personImage)
                                        as ImageProvider,
                              ),
                              title: Text(
                                data['userName'],
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                data['email'],
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  makePhoneCall(phoneNumber);
                                },
                                icon: Icon(
                                  Icons.call,
                                  color: myColor,
                                ),
                              )),
                        ),
                      ),
                    );
                  },
                );
              });
        },
      ),
    );
  }
}
