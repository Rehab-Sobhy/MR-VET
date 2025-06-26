import 'package:education_app/auth/services.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/enrolledcourse.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

class EnrolledCoursesCubit extends Cubit<EnrolledCoursesState> {
  EnrolledCoursesCubit() : super(EnrolledCoursesInitial());

  Future<void> fetchEnrolledCourses() async {
    final token = await AuthServiceClass().getToken();
    emit(EnrolledCoursesLoading());
    try {
      final response = await Dio().get(
        "https://mrvet-production.up.railway.app/api/users/me",
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final enrolledCoursesJson =
          (response.data['user']['enrolledCourses'] as List);
      final courses =
          enrolledCoursesJson.map((e) => CourseModel.fromJson(e)).toList();

      emit(EnrolledCoursesSuccess(courses));
    } catch (e) {
      emit(EnrolledCoursesFailure('فشل تحميل الدورات'));
    }
  }
}
