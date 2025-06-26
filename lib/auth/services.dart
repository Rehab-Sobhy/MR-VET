import 'package:education_app/auth/login/login_cubit.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/settings/cubitofUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServiceClass {
  static const String studentTokenKey = 'student_token';
  static const String teacherTokenKey = 'teacher_token';
  static const String currentRoleKey = 'current_role';

  Future<void> saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role == 'student') {
      await prefs.setString(studentTokenKey, token);
    } else {
      await prefs.setString(teacherTokenKey, token);
    }
    await prefs.setString(currentRoleKey, role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(currentRoleKey);
    if (role == 'student') {
      return prefs.getString(studentTokenKey);
    } else if (role == 'instructor') {
      return prefs.getString(teacherTokenKey);
    }
    return null;
  }

  Future<String?> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentRoleKey);
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();
    final role = await getCurrentRole();

    final url =
        Uri.parse('https://mrvet-production.up.railway.app/api/auth/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("Logout API status: ${response.statusCode}");
    } catch (e) {
      print("Logout API failed: $e");
    } finally {
      // Clear all relevant shared preferences
      await prefs.remove(studentTokenKey);
      await prefs.remove(teacherTokenKey);
      await prefs.remove(currentRoleKey);

      // Clear any other cached data
      await prefs.clear(); // Optional: clears ALL shared preferences

      // Reset all BLoCs/Cubits
      context.read<LoginCubit>().reset();
      context.read<ProfileCubit>().reset();

      // Navigate to login screen and remove all routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }
}
