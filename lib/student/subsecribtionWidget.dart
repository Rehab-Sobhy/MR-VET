import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/student/enrolledcourse.dart';
import 'package:education_app/student/subsercriptions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/student/courseDescription.dart';

class Subsecribtionwidget extends StatefulWidget {
  const Subsecribtionwidget({super.key});

  @override
  State<Subsecribtionwidget> createState() => _SubsecribtionwidgetState();
}

class _SubsecribtionwidgetState extends State<Subsecribtionwidget> {
  @override
  void initState() {
    super.initState();
    context.read<EnrolledCoursesCubit>().fetchEnrolledCourses();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnrolledCoursesCubit, EnrolledCoursesState>(
      builder: (context, state) {
        if (state is EnrolledCoursesLoading) {
          return const SizedBox(
              height: 150, child: Center(child: CircularProgressIndicator()));
        } else if (state is EnrolledCoursesSuccess) {
          final courses = state.courses;

          if (courses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('noSubsecriptionsYet'.tr())),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Subsicription'.tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length > 3 ? 3 : courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentCourseDetailsScreen(course: course),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: course.courseImage != null
                                    ? Image.network(
                                        "https://mrvet-production.up.railway.app/${course.courseImage!}",
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                    "assets/images/noimage.jpg",
                                                    fit: BoxFit.cover),
                                      )
                                    : Image.asset(
                                        "assets/images/noimage.jpg",
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      const Spacer(),
                                      Text(
                                        "${course.price} \LE",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is EnrolledCoursesFailure) {
          return Center(child: Text(state.error));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
