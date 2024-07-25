import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:admineventpro/presentation/pages/dashboard/message_list.dart';
import 'package:admineventpro/presentation/pages/dashboard/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SilverAppBarWidget extends StatelessWidget {
  const SilverAppBarWidget({
    super.key,
    required this.screenHeight,
    required this.coveImage,
  });

  final double screenHeight;
  final String coveImage;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return SliverAppBar.large(
      actions: [
        Transform.rotate(
          angle: 5.5,
          child: IconButton(
              onPressed: () {
                Get.to(() => MessageListScreen());
              },
              icon: Icon(Icons.send_sharp, color: Colors.white)),
        ),
        IconButton(
            onPressed: () {
              Get.to(() => NotificationScreen());
            },
            icon: Icon(Icons.notifications, color: Colors.white)),
        sizedboxWidth
      ],
      expandedHeight: 150,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
              image: coveImage.startsWith('http')
                  ? NetworkImage(coveImage)
                  : AssetImage(coveImage) as ImageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), BlendMode.darken),
            )),
        child: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              FutureBuilder<DocumentSnapshot?>(
                future: UserProfile().getUserProfile(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading profile');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('Profile not found');
                  }
                  var userName = snapshot.data!.data() as Map<String, dynamic>;
                  return Row(
                    children: [
                      Text(
                        'Hey! ${userName['companyName'] ?? 'User'}',
                        style: TextStyle(
                          fontSize: screenHeight * 0.020,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'JacquesFracois',
                        ),
                      ),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  Text(
                    'Welcome to Admin Event Pro',
                    style: TextStyle(
                        fontSize: screenHeight * 0.018,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'JacquesFracois'),
                  ),
                ],
              ),
              sizedbox,
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Your Category Template',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
