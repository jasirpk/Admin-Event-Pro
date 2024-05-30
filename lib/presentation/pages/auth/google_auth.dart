import 'dart:ui';
import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/components/back_arrow_button.dart';
import 'package:admineventpro/presentation/components/dont_have_account.dart';
import 'package:admineventpro/presentation/components/password_field.dart';
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
    final authBloc = BlocProvider.of<ManageBloc>(context);
    return BlocBuilder<ManageBloc, ManageState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is Authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => HomeScreen());
          });
        } else if (state is AuthenticatedErrors) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Error', 'Account not Registered');
          });
        }
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.18),
                      Text(
                        'Hi !',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              color:
                                  Color.fromARGB(0, 0, 0, 1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.54,
                            child: Form(
                              key: formKey,
                              child: Center(
                                child: Column(
                                  children: [
                                    TextFieldWidget(
                                      Controller: userEmailController,
                                      hintText: 'Email',
                                      obscureText: false,
                                    ),
                                    SizedBox(height: 10),
                                    PasswordField(
                                        controller: userPasswordController,
                                        hintText: 'Password'),
                                    SizedBox(height: 10),
                                    PushableButton_widget(
                                        buttonText: 'Continue',
                                        onpressed: () {
                                          final email =
                                              userEmailController.text;
                                          final password =
                                              userPasswordController.text;
                                          if (email.isEmpty ||
                                              password.isEmpty) {
                                            Get.snackbar('Error',
                                                'Please fill all fields');
                                            return;
                                          }
                                          authBloc.add(LoginEvent(
                                              email: email,
                                              password: password));
                                          // if (formKey.currentState!
                                          //     .validate()) {
                                          //   final email =
                                          //       userEmailController.text.trim();
                                          //   final password = '';
                                          //   context.read<ManageBloc>().add(
                                          //       LoginEvent(
                                          //           email: email,
                                          //           password: password));
                                          // }
                                        }),
                                    SizedBox(height: 10),
                                    Text(
                                      'Or',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SqureTile(
                                          imagePath: 'assets/images/google.png',
                                          title: 'Continue with Google',
                                        ),
                                        SizedBox(height: 10),
                                        SqureTile(
                                          imagePath:
                                              'assets/images/facebook.png',
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
