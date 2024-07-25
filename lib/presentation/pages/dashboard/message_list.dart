import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/services/users/users_profile.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_subcategory.dart';
import 'package:admineventpro/presentation/pages/dashboard/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final EventUsersProfile eventUsersProfile = EventUsersProfile();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'Admin Event Pro',
          style: TextStyle(
              color: Colors.white,
              fontSize: screenHeight * 0.028,
              letterSpacing: 1,
              fontWeight: FontWeight.w500),
        ),
      ),
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
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index];
              var profileImage = data['imagePath'];
              var userUid = documents[index].id;
              return FutureBuilder<DocumentSnapshot>(
                future: eventUsersProfile.getUserDetailById(userUid),
                builder: (context, detailSnapshot) {
                  String currentUserUid =
                      FirebaseAuth.instance.currentUser!.uid;
                  String chatId = _getChatId(currentUserUid, userUid);
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
                  var userDetails = detailSnapshot.data!;
                  return InkWell(
                    onTap: () {
                      Get.to(() => ChatScreen(
                            chatId: chatId,
                            recipientId: userUid,
                            userName: data['userName'],
                            imageUrl: profileImage,
                          ));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: CircleAvatar(
                            maxRadius: 30,
                            backgroundImage: profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : AssetImage(Assigns.personImage)
                                    as ImageProvider,
                          ),
                          title: Text(
                            data['userName'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.024,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            userDetails['email'] ?? 'No email',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                Get.to(() => ChatScreen(
                                    userName: data['userName'],
                                    imageUrl: profileImage,
                                    chatId: chatId,
                                    recipientId: userUid));
                              },
                              icon: Icon(
                                CupertinoIcons.forward,
                                color: Colors.white,
                              )),
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

// provides unique chat identifier...!

  String _getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }
}
