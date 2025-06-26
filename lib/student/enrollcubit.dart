import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/student/coursesModel.dart';
import 'enrollment_states.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  final Dio dio = Dio();

  EnrollmentCubit() : super(EnrollmentInitial());

  Future<void> checkEnrollment(CourseModel course) async {
    emit(EnrollmentLoading());
    final token = await AuthServiceClass().getToken();

    try {
      final response = await dio.get(
        '$baseUrlKey/api/courses/${course.id}/check-enrollment',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        emit(EnrollmentSuccess());
      } else if (response.statusCode == 403) {
        final message = response.data['message'] ?? 'Subscription required';
        emit(EnrollmentForbidden(message));
      } else {
        emit(EnrollmentError('Unexpected error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final message = e.response?.data['message'] ?? 'Subscription required';
        emit(EnrollmentForbidden(message));
      } else {
        emit(EnrollmentError(e.message ?? 'Failed to check enrollment'));
      }
    } catch (e) {
      emit(EnrollmentError('An unexpected error occurred'));
    }
  }
}
