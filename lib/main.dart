import 'dart:async';

import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
import 'package:admineventpro/firebase_options.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    // appleProvider: AppleProvider.debug,
  );
  runApp(AdminEventPro());
}

class AdminEventPro extends StatelessWidget {
  AdminEventPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ManageBloc()),
        BlocProvider(create: (context) => DashboardBloc()),
        BlocProvider(create: (context) => GeneratedBloc()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                    iconColor: WidgetStateProperty.all<Color>(Colors.white))),
            textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white)),
            colorScheme: ColorScheme.fromSeed(
              seedColor: myColor,
            )).copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
