import 'package:education_app/auth/forgetPass.dart/forgetScreen.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/bottomBarScreen.dart';
import 'package:education_app/homeScreen/homeScreen.dart';
import 'package:education_app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkUserStatus();
      }
    });
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    final token = await () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("auth_token");
    }();
    print("token: $token");

    if (isLoggedIn) {
      // Navigate to HomeScreen if already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
      );
    } else if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(10),
            SlideTransition(
              position: _animation,
              child: Image.asset(
                "assets/images/logowitoutBG.png",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
