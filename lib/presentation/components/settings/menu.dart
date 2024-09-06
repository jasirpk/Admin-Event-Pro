import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:admineventpro/presentation/pages/dashboard/terms_of_services.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MenuButtonWidget extends StatelessWidget {
  const MenuButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        color: Colors.white,
        iconColor: Colors.white,
        onSelected: (value) {
          if (value == 'logout') {
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
          } else if (value == 'profile') {
            Get.to(() {
              return ProfileScreen();
            });
          } else if (value == 'terms') {
            Get.to(() => TermsOfServices());
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Text(Assigns.terms),
              value: 'terms',
            ),
            PopupMenuItem(
              child: Text(Assigns.privacy),
              value: 'privacy',
            ),
            PopupMenuItem(
              child: Text(Assigns.profile),
              value: 'profile',
            ),
            PopupMenuItem(
              child: Text(Assigns.logout),
              value: 'logout',
            ),
          ];
        });
  }
}
