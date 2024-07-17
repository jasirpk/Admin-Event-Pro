import 'package:admineventpro/data_layer/services/users/users_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/pages/dashboard/events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) {
    //   return Center(
    //     child: Text("User not logged in"),
    //   );
    // }
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
                  mainAxisExtent: 100,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8),
              itemBuilder: (context, index) {
                var data = documents[index];
                var uid = documents[index].id;
                return FutureBuilder<DocumentSnapshot>(
                  future: eventUsersProfile.getUserDetailById(uid),
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
                    if (!detailSnapshot.hasData ||
                        detailSnapshot.data == null) {
                      return Center(child: Text('Details not found'));
                    }
                    return InkWell(
                      onTap: () {
                        Get.to(() => EventsListScreen(uid: uid));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        child: ListTile(
                          title: Text(
                            data['email'],
                            style: TextStyle(color: Colors.white),
                          ), // Wrapped in Text widget
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
