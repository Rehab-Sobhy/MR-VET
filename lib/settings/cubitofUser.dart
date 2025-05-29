// profile_cubit.dart
import 'dart:convert';
import 'dart:io';

import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/settings/statesofuser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ProfileCubit extends Cubit<ProfileState> {
  final String token;

  ProfileCubit({required this.token}) : super(ProfileInitial());

  Future<void> fetchUserProfile() async {
    emit(ProfileLoading());
    try {
      final response = await http.get(
        Uri.parse('$baseUrlKey/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        emit(ProfileLoaded(userData));
      } else {
        emit(ProfileError('Failed to load profile'));
      }
    } catch (e) {
      emit(ProfileError('Connection error: $e'));
    }
  }

  Future<void> updateProfileImage(String userId, File imageFile) async {
    emit(ProfileUpdating());
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

      if (response.statusCode == 200) {
        final updatedUser = json.decode(responseData);
        emit(ProfileUpdated(updatedUser));
      } else {
        emit(ProfileError('Failed to update profile image'));
      }
    } catch (e) {
      emit(ProfileError('Error updating image: $e'));
    }
  }
}
