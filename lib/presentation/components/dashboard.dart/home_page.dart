import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/data_layer/services/cover_images.dart';
import 'package:admineventpro/data_layer/services/notifications.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/cover_image.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/place_holder.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  NotificationsServices notificationsServices = NotificationsServices();
  @override
  void initState() {
    super.initState();
    notificationsServices.requestNotificationpermission();
    notificationsServices.firebaseInit(context);
    notificationsServices.setupInteractMessage(context);
    // notificationsServices.isTokenRefresh();
    notificationsServices.getDevicetoken().then((value) {
      print('Device token');
      print(value);
    });
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    CoverImageMethods coverImageMethods = CoverImageMethods();
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot?>(
        future: coverImageMethods.getCoverImage(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error loading image');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return PlaceHolderWidget(
                screenHeight: screenHeight,
                databaseMethods: databaseMethods,
                screenWidth: screenWidth);
          }
          var coverImage = snapshot.data!.data() as Map<String, dynamic>;
          return CoverImageWidget(
              screenHeight: screenHeight,
              coverImage: coverImage,
              databaseMethods: databaseMethods,
              screenWidth: screenWidth);
        },
      ),
    );
  }
}
