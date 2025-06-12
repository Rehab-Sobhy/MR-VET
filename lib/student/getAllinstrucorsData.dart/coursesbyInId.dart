import 'package:education_app/student/courseDescription.dart';
import 'package:flutter/material.dart';
import 'package:education_app/student/getAllinstrucorsData.dart/model.dart';

class InstructorCoursesScreen extends StatelessWidget {
  final InstructorModel instructor;

  const InstructorCoursesScreen({super.key, required this.instructor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(instructor.name),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: instructor.courses.isEmpty
            ? const Center(child: Text("No courses available"))
            : ListView.builder(
                itemCount: instructor.courses.length,
                itemBuilder: (context, index) {
                  final course = instructor.courses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.menu_book),
                      title: Text(course.title),
                      subtitle: Text('${course.price} \$'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailsScreen(
                              course: course,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
