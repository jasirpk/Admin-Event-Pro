import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/screens/home.dart';
import 'package:admineventpro/presentation/pages/welcome_pages/welcome_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ManageBloc>().add(login());
    return Scaffold(
      body: BlocListener<ManageBloc, ManageState>(
        listener: (context, state) {
          if (state is Authenticated) {
            print('User authenticated, navigating to HomeScreen');
            Get.offAll(() => HomeScreen());
          } else if (state is UnAthenticated) {
            print('User not authenticated, navigating to WelcomeAdmin');
            Get.off(() => WelcomeAdmin());
          }
        },
        child: BlocBuilder<ManageBloc, ManageState>(
          builder: (context, state) {
            if (state is AuthLoading || state is ManageInitial) {
              return Center(
                child: Lottie.asset(
                  'assets/images/Animation - 1716651896239.json',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  fit: BoxFit.contain,
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
