import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/courses_states.dart';

class StudentCubit extends Cubit<CourseState> {
  Dio dio = Dio();

  StudentCubit() : super(CourseInitial());

  Future<void> fetchCourses() async {
    emit(CourseLoading());
    try {
      final response = await dio.get(baseUrlKey + '/api/courses');

      List<CourseModel> courses = (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();

      emit(CourseSuccess(courses));
    } catch (e) {
      emit(CourseError("Failed to load courses: ${e.toString()}"));
    }
  }

  Future<void> checkEnrollment(CourseModel course) async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    emit(CourseEnrollmentLoading());
    try {
      final response = await dio.get(
          '${baseUrlKey}/api/courses/${course.id}/check-enrollment',
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "multipart/form-data",
            },
          ));

      if (response.statusCode == 200) {
        emit(CourseEnrollmentSuccess(course));
      } else if (response.statusCode == 403) {
        final message = response.data['message'] ?? 'Subscription required';
        emit(CourseEnrollmentForbidden(course: course, message: message));
      } else {
        emit(CourseEnrollmentError(
          course: course,
          message: 'Unexpected error: ${response.statusCode}',
        ));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final message = e.response?.data['message'] ?? 'Subscription required';
        emit(CourseEnrollmentForbidden(course: course, message: message));
      } else {
        emit(CourseEnrollmentError(
          course: course,
          message: e.message ?? 'Failed to check enrollment',
        ));
      }
    } catch (e) {
      emit(CourseEnrollmentError(
        course: course,
        message: 'An unexpected error occurred',
      ));
    }
  }

  void resetToInitial() {
    emit(CourseInitial());
  }
}
