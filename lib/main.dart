import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/firebase_options.dart';
import 'package:admineventpro/logic/bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(AdminEventPro());
}

class AdminEventPro extends StatelessWidget {
  AdminEventPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (context) => ManageBloc())],
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
                  textTheme: TextTheme(
                      bodyLarge: TextStyle(color: Colors.white),
                      bodyMedium: TextStyle(color: Colors.white)),
                  colorScheme: ColorScheme.fromSeed(seedColor: myColor))
              .copyWith(
            scaffoldBackgroundColor: Colors.black,
          ),
          home: SplashScreen(),
        ));
  }
}
