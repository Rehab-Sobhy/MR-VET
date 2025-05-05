import 'package:dio/dio.dart';
import 'package:education_app/instructor/coursesStates.dart';
import 'package:education_app/resources/apiKey.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesCubit extends Cubit<Coursesstates> {
  CoursesCubit() : super(coursesIntial());

  final Dio dio = Dio();

  Future<void> addCourse({
    required String title,
    required String description,
    required String price,
    required String instructor,
  }) async {
    emit(AddCourseLoading());
    try {
      final response = await dio.post(
        linkAddCourse, // Replace with your actual endpoint
        data: {
          'title': title,
          'description': description,
          'price': price,
          'instructor': instructor,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AddCourseSuccess());
      } else {
        emit(AddCourseFaild());
      }
    } catch (e) {
      print('Add course error: $e');
      emit(AddCourseFaild());
    }
  }
}
