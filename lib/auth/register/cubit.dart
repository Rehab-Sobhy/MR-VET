import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/auth/register/register_model.dart';
import 'package:education_app/auth/register/register_states.dart';
import 'package:education_app/resources/apiKey.dart';

import 'package:flutter/material.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  Future<void> signup(RegisterModel registerModel, BuildContext context) async {
    emit(RegisterLoading());

    try {
      print("Signing up...");

      FormData formData = FormData.fromMap({
        "email": registerModel.email,
        "name": registerModel.name,
        "role": "student",
        "password": registerModel.password,
        if (registerModel.image != null)
          "image": await MultipartFile.fromFile(registerModel.image!.path),
      });

      var dio = Dio();
      dio.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));

      var response = await dio.post(
        linkSignup,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
          },
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print("Response: ${response.statusCode} - ${response.data}");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data.containsKey("token")) {
        emit(RegisterSuccess());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else if (response.statusCode == 422) {
        // Validation error from the server
        final errors = response.data['errors'] ?? {};
        String errorMessage = '';

        if (errors.containsKey('email')) {
          errorMessage += '${"emailError".tr()}\n';
        }
        if (errors.containsKey('phone')) {
          errorMessage += '${"phoneError".tr()}\n';
        }

        emit(RegisterFailed(errMessage: errorMessage.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage.trim())),
        );
      } else {
        emit(RegisterFailed(errMessage: response.data.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ غير متوقع، حاول مرة أخرى')),
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
