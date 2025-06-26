import 'dart:io';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';

import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class InstructorCoursesCubit extends Cubit<CourseState> {
  InstructorCoursesCubit() : super(CourseInitial());

  final Dio dio = Dio();

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> addCourse({
    required String title,
    required String description,
    required double price,
    required String category,
    File? courseImage, // Optional image
  }) async {
    emit(AddCourseLoading());
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final Map<String, dynamic> formFields = {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
      };

      // Add image if exists
      if (courseImage != null) {
        String extension =
            path.extension(courseImage.path).toLowerCase().replaceAll('.', '');
        String mimeType = 'jpeg'; // default

        if (extension == 'png') {
          mimeType = 'png';
        } else if (extension == 'jpg' || extension == 'jpeg') {
          mimeType = 'jpeg';
        } else {
          throw Exception('Unsupported image format');
        }

        formFields['courseImage'] = await MultipartFile.fromFile(
          courseImage.path,
          filename: path.basename(courseImage.path),
          contentType: MediaType('image', mimeType),
        );
      }

      FormData formData = FormData.fromMap(formFields);

      final response = await dio.post(
        "$baseUrlKey/api/courses/create",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print('✅ Response: ${response.statusCode}');
      print('✅ Data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AddCourseSuccess());
      } else {
        emit(AddCourseFaild());
      }
    } catch (e) {
      print('❌ DioException: $e');
      emit(AddCourseFaild());
    }
  }

  Future<void> fetchCourses() async {
    emit(MyCourseLoading());
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final response = await Dio().get(
        'https://mrvet-production.up.railway.app/api/courses/my-courses',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print(response);
      if (response.statusCode == 200) {
        final List<CourseModel> courses = (response.data['courses'] as List)
            .map((course) => CourseModel.fromJson(course))
            .toList();
        emit(MyCourseSuccess(courses));
      } else {
        emit(MyCourseError('فشل في جلب الكورسات: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MyCourseError('حدث خطأ أثناء جلب الكورسات: $e'));
      print(e);
    }
  }

  Future<void> UpdateCourse({
    required String CourseId,
    required String title,
    required String description,
    required double price,
    required String category,
    File? courseImage,
  }) async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    emit(UpdateCourseLoading());

    try {
      final Map<String, dynamic> formFields = {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
      };

      if (courseImage != null) {
        String extension =
            path.extension(courseImage.path).toLowerCase().replaceAll('.', '');
        String mimeType = 'jpeg'; // default

        if (extension == 'png') {
          mimeType = 'png';
        } else if (extension == 'jpg' || extension == 'jpeg') {
          mimeType = 'jpeg';
        } else {
          throw Exception('Unsupported image format');
        }

        formFields['courseImage'] = await MultipartFile.fromFile(
          courseImage.path,
          filename: path.basename(courseImage.path),
          contentType: MediaType('image', mimeType),
        );
      }

      FormData formData = FormData.fromMap(formFields);

      final response = await dio.put(
        "$baseUrlKey/api/courses/$CourseId",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print('✅ Response: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdateCourseSuccess());
      } else {
        emit(UpdateCourseFaild());
      }
    } catch (e) {
      print('❌ DioException: $e');
      emit(UpdateCourseFaild());
    }
  }

  Future<void> DeleteCourse({
    required String CourseId,
  }) async {
    emit(DeleteCourseLoading());
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final response = await dio.delete(
        "$baseUrlKey/api/courses/$CourseId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print('✅ Response: ${response.statusCode}');
      print('✅ Data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteCourseSuccess());

        fetchCourses();
      } else {
        emit(DeleteCoursefiled());
      }
    } catch (e) {
      print('❌ DioException: $e');
      emit(DeleteCoursefiled());
    }
  }
}
