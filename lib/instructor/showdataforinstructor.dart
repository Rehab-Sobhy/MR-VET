import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/instructor/InscoursesCubit.dart';
import 'package:education_app/instructor/coursesVideos.dart';
import 'package:education_app/instructor/uploadVideao.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsCourses extends StatefulWidget {
  const InsCourses({super.key});

  @override
  State<InsCourses> createState() => _InsCoursesState();
}

class _InsCoursesState extends State<InsCourses> {
  void initState() {
    super.initState();
    context.read<InstructorCoursesCubit>().fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<InstructorCoursesCubit, CourseState>(
        builder: (context, state) {
          if (state is MyCourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyCourseError) {
            return Center(child: Text(state.message));
          } else if (state is MyCourseSuccess) {
            final courses = state.courses;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  const Gap(20),
                  _buildSectionHeader("courses", context),
                  const Gap(8),
                  _buildCoursesGrid(courses, context),
                  const Gap(20),
                ],
              ),
            );
          }
          return const Center(child: Text("No content available"));
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            "showall".tr(),
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorsList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(), // Smooth horizontal scrolling
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 130,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  "assets/images/check2.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursesGrid(List<dynamic> courses, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Disable GridView scroll
        itemCount: courses.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final course = courses[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoUploadScreen(
                    id: course.id,
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: course.courseImage != null
                        ? Image.network(
                            "https://e-learinng-production.up.railway.app/${course.courseImage!}",
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              "assets/images/check2.jpg",
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            "assets/images/check2.jpg",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "${course.price} \$",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    child: Icon(Icons.video_call),
                    onTap: () {
                      print("qqqqqqqqqqqq ${course.id}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideosScreen(
                            courseId: course.id,
                            courseTitle: course.title,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
