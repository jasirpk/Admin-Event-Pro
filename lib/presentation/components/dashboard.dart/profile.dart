import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            context.read<ManageBloc>().add(Logout());
            context.read<ManageBloc>().add(SignOutWithGoogle());
            context.read<ManageBloc>().add(SignOutWithFacebook());
          },
          icon: Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
        BlocListener<ManageBloc, ManageState>(
          listener: (context, state) {
            if (state is UnAthenticated) {
              Get.off(() => GoogleAuthScreen());
            } else if (state is AuthenticatedErrors) {
              Get.snackbar('Logout Error', state.message,
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: Column(
            children: [
              Center(
                child: Text('Exit'),
              ),
              sizedbox,
              ElevatedButton(
                  onPressed: () {
                    Get.to(() {
                      return ProfileScreen();
                    });
                  },
                  child: Text('User Profile'))
            ],
          ),
        ),
      ],
    );
  }
}
