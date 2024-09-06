import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:admineventpro/presentation/pages/dashboard/privacy_plicy.dart';
import 'package:admineventpro/presentation/components/settings/menu.dart';
import 'package:admineventpro/presentation/components/settings/user_profile.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:admineventpro/presentation/pages/dashboard/cover_images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late Future<DocumentSnapshot> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = UserProfile().getUserProfile(uid);
  }

  void _refreshData() {
    setState(() {
      _userProfileFuture = UserProfile().getUserProfile(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> items = [
      {
        'icon': Icons.share,
        'text': 'Share this App',
        'onTap': () {
          Share.share('https://www.amazon.com/dp/B0DC3KH2M8/ref=apps_sf_sta');
        }
      },
      {
        'icon': Icons.preview,
        'text': 'Privacy Policy',
        'onTap': () {
          Get.to(
            () => PrivacyPlicy(),
          );
        }
      },
      {
        'icon': Icons.collections_bookmark,
        'text': 'Cover Images',
        'onTap': () {
          Get.to(() => CoverImages());
        }
      },
      {
        'icon': Icons.logout,
        'text': 'Exit Application',
        'onTap': () {
          Get.defaultDialog(
              title: 'Exit? ⚠️',
              middleText: 'Do you want logout?',
              textCancel: 'Cancel',
              textConfirm: 'Log Out',
              middleTextStyle: TextStyle(color: Colors.black),
              onCancel: () {
                Get.back();
              },
              onConfirm: () {
                Get.offAll(() => GoogleAuthScreen());
                context.read<ManageBloc>().add(Logout());
                context.read<ManageBloc>().add(SignOutWithGoogle());
                // context.read<ManageBloc>().add(SignOutWithFacebook());
              });
        }
      },
    ];
    return BlocListener<ManageBloc, ManageState>(
      listener: (context, state) {
        if (state is UnAthenticated) {
          Get.off(() => GoogleAuthScreen());
        } else if (state is AuthenticatedErrors) {
          Get.snackbar('Logout Error', state.message,
              snackPosition: SnackPosition.BOTTOM);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
            MenuButtonWidget(),
            sizedboxWidth,
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                !snapshot.data!.exists ||
                snapshot.hasError) {
              return Center(child: Text('No data'));
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return UserProfileWidget(
                userData: userData, screenHeight: screenHeight, items: items);
          },
        ),
      ),
    );
  }
}
