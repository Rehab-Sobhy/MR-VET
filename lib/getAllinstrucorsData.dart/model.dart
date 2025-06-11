import 'package:education_app/student/coursesModel.dart';

class InstructorModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String collegeId;
  final List<CourseModel> courses;

  InstructorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.collegeId,
    required this.courses,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profileImage: json['profileImage'],
      collegeId: json['collegeId'],
      courses: (json['courses'] as List)
          .map((course) => CourseModel.fromJson(course))
          .toList(),
    );
  }
}
