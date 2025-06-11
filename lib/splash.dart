import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/instructor/instructorHomeScreen.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/student/bottomBarScreen.dart';
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
  final AuthServiceClass _authService = AuthServiceClass();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _navigateAfterDelay();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    final token = await _authService.getToken();
    final role = await _authService.getCurrentRole();

    debugPrint("Token: $token");
    debugPrint("Role: $role");

    if (token != null) {
      if (role == 'instructor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => InsHomeScreen()),
        );
      } else if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomBarScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
