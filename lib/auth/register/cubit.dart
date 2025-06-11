import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/auth/register/register_model.dart';
import 'package:education_app/auth/register/register_states.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  Future<void> signup(RegisterModel registerModel, BuildContext context) async {
    emit(RegisterLoading());

    // Validate required fields
    if (registerModel.name.trim().isEmpty ||
        registerModel.email.trim().isEmpty ||
        registerModel.password.trim().isEmpty) {
      final errorMsg = 'كل الحقول مطلوبة';
      emit(RegisterFailed(errMessage: errorMsg));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return;
    }

    try {
      final formFields = {
        "email": registerModel.email!.trim(),
        "name": registerModel.name!.trim(),
        "role": registerModel.role,
        "password": registerModel.password!.trim(),
      };

      if (registerModel.profileImage != null) {
        String extension = path
            .extension(registerModel.profileImage!.path)
            .toLowerCase()
            .replaceAll('.', '');
        String mimeType = 'jpeg';

        if (extension == 'png') {
          mimeType = 'png';
        } else if (extension == 'jpg' || extension == 'jpeg') {
          mimeType = 'jpeg';
        } else {
          throw Exception('صيغة الصورة غير مدعومة');
        }
        formFields['profileImage'] = await MultipartFile.fromFile(
          registerModel.profileImage!.path,
          filename: path.basename(registerModel.profileImage!.path),
          contentType: MediaType('image', mimeType),
        );

        formFields['collegeId'] = await MultipartFile.fromFile(
          registerModel.profileImage!.path,
          filename: path.basename(registerModel.profileImage!.path),
          contentType: MediaType('image', mimeType),
        );
      }

      final formData = FormData.fromMap(formFields);

      final dio = Dio();
      dio.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));

      final response = await dio.post(
        linkSignup,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data.containsKey("token")) {
        // Save token and role if returned
        final token = response.data["token"];
        final role = response.data["user"]?["role"] ?? registerModel.role;

        final authService = AuthServiceClass();
        await authService.saveToken(token, role);

        emit(RegisterSuccess());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      print("Register Error: $e");
      emit(RegisterFailed(errMessage: e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الاتصال بالخادم')),
      );
    }
  }
}
