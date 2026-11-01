import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';

// Mirrored by the native launch screens: android launch_background.xml and the
// iOS LaunchImage asset both draw kSplashLogoAsset centred at kSplashLogoWidth.
const String kSplashLogoAsset = 'assets/images/admin event pro.png';
const String kSplashAnimationAsset =
    'assets/images/Animation - 1716651896239.json';

// 745px in the xxhdpi bucket and 248pt at iOS 1x both resolve to 248dp.
const double kSplashLogoWidth = 248;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<ManageBloc>().add(CheckUserEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ManageBloc, ManageState>(
        builder: (context, state) {
          if (state is AuthLoading || state is ManageInitial) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Centred exactly as the native launch screen draws it, so the
                // logo does not move when Flutter takes over.
                Center(
                  child: Image.asset(
                    kSplashLogoAsset,
                    width: kSplashLogoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.6),
                  child: Lottie.asset(
                    kSplashAnimationAsset,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
