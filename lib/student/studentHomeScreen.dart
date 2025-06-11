import 'package:education_app/constants/widgets/customAppBar.dart';
import 'package:education_app/getAllinstrucorsData.dart/coursesbyInId.dart';
import 'package:education_app/getAllinstrucorsData.dart/cubit.dart';
import 'package:education_app/getAllinstrucorsData.dart/states.dart';
import 'package:education_app/settings/cubitofUser.dart';
import 'package:education_app/student/courseDescription.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:education_app/student/studentCubit.dart';
import 'package:education_app/student/subsecribtionWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentCubit>().fetchCourses();
    context.read<InstructorCubit>().fetchInstructors();
    context.read<ProfileCubit>().fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<StudentCubit, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return _buildShimmerLoading();
          } else if (state is CourseError) {
            return Center(child: Text(state.message));
          } else if (state is CourseSuccess) {
            final courses = state.courses;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Subsecribtionwidget(),
                ),
                SliverToBoxAdapter(
                  child: _buildInstructorsSection(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildCourseCard(courses[index], context);
                      },
                      childCount: courses.length,
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text("No content available"));
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header shimmer
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 16),
        ),

        // Courses shimmer
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstructorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'instructors'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: BlocBuilder<InstructorCubit, InstructorState>(
            builder: (context, state) {
              if (state is InstructorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InstructorFailure) {
                return Center(child: Text(state.error));
              } else if (state is InstructorSuccess) {
                final instructors = state.instructors;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: instructors.length,
                  itemBuilder: (context, index) {
                    final instructor = instructors[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                InstructorCoursesScreen(instructor: instructor),
                          ),
                        );
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: instructor.profileImage != null
                                    ? Image.network(
                                        "https://mrvet-production.up.railway.app/${instructor.profileImage!}",
                                        width: double.infinity,
                                        fit: BoxFit.fill,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "assets\images\noimage.jpg",
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    : Image.asset(
                                        "assets\images\noimage.jpg",
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              instructor.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${instructor.courses.toList().length} courses',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(dynamic course, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(course: course),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: course.courseImage != null
                    ? Image.network(
                        "https://mrvet-production.up.railway.app/${course.courseImage!}",
                        width: double.infinity,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          "assets\images\noimage.jpg",
                          fit: BoxFit.fill,
                        ),
                      )
                    : Image.asset(
                        "assets\images\noimage.jpg",
                        width: double.infinity,
                        fit: BoxFit.fill,
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
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${course.price} \$",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
  }
}
