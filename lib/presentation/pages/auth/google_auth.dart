import 'dart:ui';
import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/components/back_arrow_button.dart';
import 'package:admineventpro/presentation/components/dont_have_account.dart';
import 'package:admineventpro/presentation/components/pushable_button.dart';
import 'package:admineventpro/presentation/components/squre_tile.dart';
import 'package:admineventpro/presentation/components/text_field.dart';
import 'package:admineventpro/presentation/pages/auth/signup.dart';
import 'package:admineventpro/presentation/pages/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class GoogleAuth extends StatelessWidget {
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/google_ath_img.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: BackArrowButton(
                      onpressed: () {
                        Get.back();
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  Text(
                    'Hi !',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 0, 0, 1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: Form(
                          key: formKey,
                          child: Center(
                            child: BlocListener<ManageBloc, ManageState>(
                              listener: (context, state) {
                                if (state is Authenticated) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    Get.off(() => SignupScreen());
                                  });
                                } else if (state is ValidatonSuccess) {
                                  // UserModel user = UserModel(
                                  //   email: userEmailController.text,
                                  //   password: userPasswordController.text,
                                  // );
                                  context.read<ManageBloc>().add(ValidateFields(
                                      Email:
                                          userEmailController.text.toString(),
                                      Password: userPasswordController.text));
                                } else if (state is AuthenticatedErrors) {
                                  Get.snackbar('Error', state.message);
                                }
                              },
                              child: Column(
                                children: [
                                  TextFieldWidget(
                                    Controller: userEmailController,
                                    hintText: 'Email',
                                    obscureText: false,
                                  ),
                                  SizedBox(height: 10),
                                  PushableButton_widget(
                                    buttonText: 'Continue',
                                    onpressed: () {
                                      if (formKey.currentState!.validate()) {
                                        final email = userEmailController.text;
                                        final password =
                                            userPasswordController.text;
                                        context.read<ManageBloc>().add(
                                            LoginEvent(
                                                email: email,
                                                password: password));
                                      }
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Or',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SqureTile(
                                        imagePath: 'assets/images/google.png',
                                        title: 'Continue with Google',
                                      ),
                                      SizedBox(height: 10),
                                      SqureTile(
                                        imagePath: 'assets/images/facebook.png',
                                        title: 'Continue with Facebook',
                                      ),
                                      SizedBox(height: 10),
                                      DontHaveAccount(
                                        onpressed: () {
                                          Get.to(() => SignupScreen());
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
