import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ManageBloc>().add(Logout());
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              final manageBloc = BlocProvider.of<ManageBloc>(context);
              manageBloc.add(Logout());
              Get.off(() => SignupScreen());
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
