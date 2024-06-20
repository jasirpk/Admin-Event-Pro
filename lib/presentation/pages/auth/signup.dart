import 'dart:ui';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/entities/logic_models/admin_auth.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/components/auth/auth_bottom_text.dart';
import 'package:admineventpro/presentation/components/ui/back_arrow_button.dart';
import 'package:admineventpro/presentation/components/auth/password_field.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/auth/text_field.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:admineventpro/presentation/pages/dashboard/home.dart';
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
      body: BlocListener<ManageBloc, ManageState>(
        listener: (context, state) {
          if (state is Authenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar('Error', 'Successfully Registed');
              Get.offAll(() => HomeScreen());
            });
          } else if (state is ValidatonSuccess) {
            UserModel user = UserModel(
              email: userEmailController.text,
              password: userPasswordController.text,
            );
            context.read<ManageBloc>().add(SignUp(userModel: user));
          } else if (state is AuthenticatedErrors) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar('Error', 'Account not Registered');
            });
          }
        },
        child: SingleChildScrollView(
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Sign Up',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.50,
                          child: Form(
                            key: formKey,
                            child: Center(
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
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: PushableButton_widget(
                                        buttonText: 'Agree and Continue',
                                        onpressed: () {
                                          if (formKey.currentState!
                                              .validate()) {
                                            final email =
                                                userEmailController.text;
                                            final password =
                                                userPasswordController.text;
                                            context
                                                .read<ManageBloc>()
                                                .add(SignUp(
                                                  userModel: UserModel(
                                                      email: email,
                                                      password: password),
                                                ));
                                          }
                                        }),
                                  ),
                                  SizedBox(height: 10),
                                  AuthBottomText(
                                      onpressed: () {
                                        Get.to(() => GoogleAuthScreen());
                                      },
                                      text: 'Already have an account?',
                                      subText: 'Login')
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
      ),
    );
  }
}
