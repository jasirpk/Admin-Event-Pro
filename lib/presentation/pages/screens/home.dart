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
    context.read<ManageBloc>().add(Logout());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        actions: [
          IconButton(
            onPressed: () {
              final manageBloc = BlocProvider.of<ManageBloc>(context);
              manageBloc.add(Logout());
              Get.off(() => GoogleAuth());
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
