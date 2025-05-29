import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/courses_states.dart';

class StudentCourseCubit extends Cubit<CourseState> {
  StudentCourseCubit() : super(CourseInitial());

  Future<void> fetchCourses() async {
    emit(CourseLoading());
    try {
      final response =
          await Dio().get(linkAllCourses); // replace with actual URL

      List<CourseModel> courses = (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();

      emit(CourseSuccess(courses));
    } catch (e) {
      emit(CourseError("Failed to load courses: $e"));
    }
  }
}
