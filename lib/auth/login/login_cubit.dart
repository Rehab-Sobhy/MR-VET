import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:education_app/auth/login/login_states.dart';
import 'package:education_app/auth/services.dart'; // import your AuthServiceClass

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      if (kDebugMode) {
        print("Logging in...");
      }

      final response = await Dio().post(
        "https://mrvet-production.up.railway.app/api/auth/login",
        data: jsonEncode({
          "email": email,
          "password": password,
        }),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (kDebugMode) {
        print("Response: ${response.data}");
      }

      if (response.data.containsKey("token")) {
        String token = response.data["token"];
        final role = response.data['user']['role'];

        await _saveToken(token, role);
        emit(LoginSuccess(token: token));
        if (kDebugMode) {
          print("Login Successful: $token");
        }
      } else {
        emit(LoginFailed(errMessage: response.data.toString()));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login Error: $e");
      }
      emit(LoginFailed(errMessage: e.toString()));
    }
  }

  Future<void> _saveToken(String token, String role) async {
    final authService = AuthServiceClass();
    await authService.saveToken(token, role);
    if (kDebugMode) {
      print("Token saved successfully");
    }
  }
}
