import 'dart:ui';

import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/components/back_arrow_button.dart';
import 'package:admineventpro/presentation/components/password_field.dart';
import 'package:admineventpro/presentation/components/pushable_button.dart';
import 'package:admineventpro/presentation/components/text_field.dart';
import 'package:admineventpro/presentation/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();

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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: BackArrowButton(
                      onpressed: () {
                        Get.back();
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.26),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Sign Up',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Form(
                          key: formKey,
                          child: Center(
                            child: BlocListener<ManageBloc, ManageState>(
                              listener: (context, state) {
                                if (state is ValidatonSuccess) {
                                  Get.to(() => LoginScreen());
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      "Looks like you don't have an account. Let's create a new account",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: TextFieldWidget(
                                      Controller: userEmailController,
                                      hintText: 'Email',
                                      obscureText: false,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: PasswordField(
                                      controller: userPasswordController,
                                      hintText: 'Password',
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: RichText(
                                      text: TextSpan(
                                        text:
                                            'By selecting Agree & Continue below, I agree to our ',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                'Terms of Service and Privacy Policy',
                                            style: TextStyle(
                                              color: myColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: PushableButton_widget(
                                      buttonText: 'Agree and Continue',
                                      onpressed: () {
                                        final email = userEmailController.text;
                                        final password =
                                            userPasswordController.text;
                                        context.read<ManageBloc>().add(
                                            ValidateFields(
                                                Email: email,
                                                Password: password));
                                      },
                                    ),
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
