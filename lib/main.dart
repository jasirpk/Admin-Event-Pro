import 'dart:async';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/firebase_options.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    providerAndroid: AndroidDebugProvider(),
    providerApple: AppleDebugProvider()
  );
  await _warmSplashAssets();
  runApp(AdminEventPro());
}

// Decode the splash logo and Lottie composition before the first frame so the
// Flutter splash paints the artwork the native launch screen is already
// showing, instead of a blank frame followed by a pop-in.
Future<void> _warmSplashAssets() async {
  try {
    await Future.wait(<Future<void>>[
      AssetLottie(kSplashAnimationAsset).load().then((_) {}),
      _decodeAsset(const AssetImage(kSplashLogoAsset)),
    ]);
  } catch (error) {
    // Warm-up is only an optimisation; the widgets load these assets
    // themselves on first build, so a failure must not block startup.
    debugPrint('Splash asset warm-up skipped: $error');
  }
}

Future<void> _decodeAsset(ImageProvider provider) {
  final completer = Completer<void>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  void finish() {
    stream.removeListener(listener);
    if (!completer.isCompleted) completer.complete();
  }

  listener = ImageStreamListener(
    (_, __) => finish(),
    onError: (_, __) => finish(),
  );
  stream.addListener(listener);
  return completer.future;
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
        BlocProvider(create: (context) => ProfileBloc()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
