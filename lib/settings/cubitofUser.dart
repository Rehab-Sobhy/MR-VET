import 'dart:convert';
import 'dart:io';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/settings/statesofuser.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ProfileCubit extends Cubit<ProfileState> {
  String? token;
  final AuthServiceClass authService =
      AuthServiceClass(); // AuthService instance
  List<CourseModel> enrolledCourses = [];

  ProfileCubit() : super(ProfileInitial());

  // Call this method first to load token before API calls
  Future<void> loadToken() async {
    token = await authService.getToken();
  }

  Future<void> fetchUserProfile() async {
    if (isClosed) return;
    emit(ProfileLoading());

    await loadToken();

    if (token == null) {
      emit(ProfileError('No auth token found'));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrlKey/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('API response status: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (!isClosed) {
        if (response.statusCode == 200) {
          final userData = json.decode(response.body);

          final coursesJson = userData['user']['enrolledCourses'] as List;
          enrolledCourses = coursesJson.map((courseJson) {
            return CourseModel.fromJson(courseJson);
          }).toList();

          emit(ProfileLoaded(userData));
        } else {
          emit(ProfileError('Failed to load profile'));
        }
      }
    } catch (e) {
      if (!isClosed) emit(ProfileError('Connection error: $e'));
    }
  }

  Future<void> updateProfileImage(String userId, File imageFile) async {
    if (isClosed) return;
    emit(ProfileUpdating());

    await loadToken();

    if (token == null) {
      emit(ProfileError('No auth token found'));
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrlKey/api/users/$userId/profile-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (!isClosed) {
        if (response.statusCode == 200) {
          final updatedUser = json.decode(responseData);
          emit(ProfileUpdated(updatedUser));
        } else {
          emit(ProfileError('Failed to update profile image'));
        }
      }
    } catch (e) {
      if (!isClosed) emit(ProfileError('Error updating image: $e'));
    }
  }
}
