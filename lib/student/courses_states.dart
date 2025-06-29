import 'package:education_app/student/coursesModel.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseSuccess extends CourseState {
  final List<CourseModel> courses;

  CourseSuccess(this.courses);
}

class CourseError extends CourseState {
  final String message;

  CourseError(this.message);
}

class MyCourseLoading extends CourseState {}

class MyCourseSuccess extends CourseState {
  final List<CourseModel> courses;

  MyCourseSuccess(this.courses);
}

class MyCourseError extends CourseState {
  final String message;

  MyCourseError(this.message);
}

class AddCourseSuccess extends CourseState {}

class AddCourseFaild extends CourseState {
  AddCourseFaild();
}

class AddCourseLoading extends CourseState {}

class UpdateCourseSuccess extends CourseState {}

class UpdateCourseFaild extends CourseState {
  UpdateCourseFaild();
}

class UpdateCourseLoading extends CourseState {}

class DeleteCourseLoading extends CourseState {}

class DeleteCourseSuccess extends CourseState {}

class DeleteCoursefiled extends CourseState {
  DeleteCoursefiled();
}
