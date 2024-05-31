import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/auth/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ManageBloc>().add(Logout());
              context.read<ManageBloc>().add(SignOutWithGoogle());
              context.read<ManageBloc>().add(SignOutWithFacebook());
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: BlocListener<ManageBloc, ManageState>(
        listener: (context, state) {
          if (state is UnAthenticated) {
            Get.off(() => GoogleAuthScreen());
          } else if (state is AuthenticatedErrors) {
            Get.snackbar('Logout Error', state.message,
                snackPosition: SnackPosition.BOTTOM);
          }
        },
        child: Center(
          child: Text('Home Page'),
        ),
      ),
    );
  }
}
