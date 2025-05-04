import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/auth/login/login_states.dart';
import 'package:education_app/resources/apiKey.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  Future<String?> getFcm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("fcm_token");
  }

  Future<void> login(String email, String password) async {
    final fcmToken = await getFcm();
    emit(LoginLoading());
    try {
      print("Logging in...");

      var response = await Dio().post(
        linkLogin,
        data: {
          "email": email,
          "password": password,
          "fcm_token": fcmToken,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

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

  Future<void> Otp(String phone, String otp) async {
    final fcmToken = await getFcm();
    emit(LoginLoading());
    try {
      print("Logging in...");

      var response = await Dio().post(
        linkOtp,
        data: {
          "phone": phone,
          "otp": otp,
          "fcm_token": fcmToken,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data.containsKey("token")) {
        String token = response.data["token"];
        await _saveToken(token);
        emit(LoginSuccess(token: token));
        print("Login Successful: $token");
      } else {
        emit(LoginFailed(errMessage: "errorTryAgain".tr()));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login Error: $e");
      }
      emit(LoginFailed(errMessage: "errorTryAgain".tr()));
    }
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setBool("isLoggedIn", true); // Save login status
    print("Token saved successfully");
  }
}
