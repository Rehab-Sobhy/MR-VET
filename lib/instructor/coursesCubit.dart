import 'dart:io';
import 'package:dio/dio.dart';
import 'package:education_app/resources/apiKey.dart';
import 'package:http_parser/http_parser.dart';
import 'package:education_app/instructor/coursesStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class CoursesCubit extends Cubit<Coursesstates> {
  CoursesCubit() : super(coursesIntial());

  final Dio dio = Dio();

  get linkBaseUrl => null;

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
    String? token = await getToken();
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
        "$linkBaseUrl/api/courses/create",
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
}
