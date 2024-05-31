import 'package:admineventpro/presentation/components/pushable_button.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/welcome_carousal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_admin_img.webp',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(1),
                  Colors.black.withOpacity(0.1)
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Welcome to\nAdmin Event Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'JacquesFracois',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Streamline event management effortlessly with our intuitive admin app. Take charge of every detail with ease, from vendor coordination to budget tracking...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: PushableButton_widget(
                        buttonText: 'Get Started',
                        onpressed: () {
                          Get.to(() => CarousalWelcome());
                        })),
              ],
            ),
          )
        ],
      ),
    );
  }
}
