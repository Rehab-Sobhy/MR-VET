import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:education_app/auth/login/login_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      print("Logging in...");

      final response = await Dio().post(
        "https://e-learinng-production.up.railway.app/api/auth/login",
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

      print("Response: ${response.data}");

      if (response.data.containsKey("token")) {
        String token = response.data["token"];
        await _saveToken(token);
        emit(LoginSuccess(token: token));
        print("Login Successful: $token");
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

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);

    await prefs.setBool("isLoggedIn", true);
    print("Token saved successfully");
  }
}
