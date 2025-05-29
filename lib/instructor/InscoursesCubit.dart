import 'dart:io';
import 'package:dio/dio.dart';
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
    String? token = auth;
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

      if (token == null) {
        emit(AddCourseFaild());
        print("❌ No token found");
        return;
      }

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

    try {
      final response = await Dio().get(
        'https://e-learinng-production.up.railway.app/api/courses/my-courses',
        options: Options(
          headers: {
            'Authorization': 'Bearer $auth',
          },
        ),
      );

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
    }
  }
}
