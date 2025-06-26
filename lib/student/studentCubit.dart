import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/student/coursesModel.dart';
import 'package:education_app/student/courses_states.dart';

class StudentCubit extends Cubit<CourseState> {
  final Dio dio = Dio();
  List<CourseModel> _courses = []; // <-- حفظ الكورسات هنا

  StudentCubit() : super(CourseInitial());

  Future<void> fetchCourses() async {
    emit(CourseLoading());
    try {
      final response = await dio.get(baseUrlKey + '/api/courses');

      _courses = (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();

      emit(CourseSuccess(_courses));
    } catch (e) {
      emit(CourseError("فشل في تحميل الكورسات: ${e.toString()}"));
    }
  }

  /// 🔄 لحل مشكلة الصفحة البيضاء: إعادة الحالة للكورسات المحفوظة
  void resetToCourses() {
    emit(CourseSuccess(_courses));
  }
}
