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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    // Call API logout with DELETE
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final role = await getCurrentRole();
        if (role == 'student') {
          await prefs.remove(studentTokenKey);
        } else if (role == 'instructor') {
          await prefs.remove(teacherTokenKey);
        }
        await prefs.remove(currentRoleKey);
      } else {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }
}
