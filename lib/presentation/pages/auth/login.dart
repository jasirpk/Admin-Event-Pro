import 'dart:ui';

import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/components/back_arrow_button.dart';
import 'package:admineventpro/presentation/components/dont_have_account.dart';
import 'package:admineventpro/presentation/components/password_field.dart';
import 'package:admineventpro/presentation/components/pushable_button.dart';
import 'package:admineventpro/presentation/pages/auth/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final userPasswordController = TextEditingController();
  final userEmailController = TextEditingController();

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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  BackArrowButton(
                    onpressed: () {
                      Get.back();
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Text(
                    'Log in',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  sizedbox,
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(0, 0, 0, 1).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30)),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Form(
                            key: formKey,
                            child: Center(
                              child: BlocListener<ManageBloc, ManageState>(
                                listener: (context, state) {
                                  if (state is ValidatonSuccess) {
                                    Get.to(() => GoogleAuth());
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: myColor, width: 2.0),
                                            ),
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundImage: AssetImage(
                                                  'assets/images/google_ath_img.jpg'),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'PK Events',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'sample.213@gmail.com',
                                                style: TextStyle(fontSize: 18),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    PasswordField(
                                      controller: userPasswordController,
                                      hintText: 'Password',
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    PushableButton_widget(
                                        buttonText: 'Continue',
                                        onpressed: () {}),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                          color: myColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    DontHaveAccount(
                                      onpressed: () {
                                        Get.back();
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
