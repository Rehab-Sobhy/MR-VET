import 'package:education_app/student/coursesModel.dart';

abstract class EnrolledCoursesState {}

class EnrolledCoursesInitial extends EnrolledCoursesState {}

class EnrolledCoursesLoading extends EnrolledCoursesState {}

class EnrolledCoursesSuccess extends EnrolledCoursesState {
  final List<CourseModel> courses;

  EnrolledCoursesSuccess(this.courses);
}

class EnrolledCoursesFailure extends EnrolledCoursesState {
  final String error;

  EnrolledCoursesFailure(this.error);
}
