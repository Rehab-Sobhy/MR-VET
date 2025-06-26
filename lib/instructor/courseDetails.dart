import 'package:education_app/instructor/InscoursesCubit.dart';
import 'package:education_app/instructor/Materilas.dart';
import 'package:education_app/instructor/courses_Videos.dart';
import 'package:education_app/instructor/editCourse.dart';
import 'package:education_app/instructor/instructorHomeScreen.dart';
import 'package:education_app/instructor/uploadVideao.dart';
import 'package:education_app/instructor/upload_Materials.dart';
import 'package:education_app/student/courses_states.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class CourseDetailsScreen extends StatefulWidget {
  final dynamic course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<InstructorCoursesCubit, CourseState>(
        listener: (context, state) {
          if (state is DeleteCourseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("course.delete_success".tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InsHomeScreen()));
          }
          if (state is DeleteCoursefiled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("course.delete_failed".tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: size.height * 0.35,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.course.courseImage != null
                              ? Image.network(
                                  "https://mrvet-production.up.railway.app/${widget.course.courseImage!}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultImage(),
                                )
                              : _buildDefaultImage(),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pinned: true,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditCourseScreen(
                                        course: widget.course,
                                      )));
                        },
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.course.title,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ).animate().fadeIn(delay: 100.ms),
                                    const Gap(8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Chip(
                                          backgroundColor: theme
                                              .colorScheme.primaryContainer,
                                          label: Text(
                                            '4.8 ★',
                                            style: TextStyle(
                                                color: theme.colorScheme
                                                    .onPrimaryContainer),
                                          ),
                                          avatar: Icon(Icons.star,
                                              size: 16,
                                              color: theme.colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                        Chip(
                                          backgroundColor: theme
                                              .colorScheme.secondaryContainer,
                                          label: Text(
                                            "course.hours".tr(args: ['12']),
                                            style: TextStyle(
                                                color: theme.colorScheme
                                                    .onSecondaryContainer),
                                          ),
                                          avatar: Icon(Icons.timer_outlined,
                                              size: 16,
                                              color: theme.colorScheme
                                                  .onSecondaryContainer),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade600,
                                      Colors.orange,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "${widget.course.price} \$",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                                  .animate(
                                      onPlay: (controller) =>
                                          controller.repeat())
                                  .shimmer(duration: 2000.ms),
                            ],
                          ),
                          const Gap(24),
                          InkWell(
                            onTap: () =>
                                setState(() => _isExpanded = !_isExpanded),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "course.description".tr(),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        _isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                  AnimatedCrossFade(
                                    firstChild: Text(
                                      widget.course.description ??
                                          "course.no_description".tr(),
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    secondChild: Text(
                                      widget.course.description ??
                                          "course.no_description".tr(),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    crossFadeState: _isExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 200),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildActionCard(
                          context,
                          icon: Icons.play_circle_fill,
                          label: "course.videos".tr(),
                          subtitle: "course.videos_count".tr(args: ['12']),
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideosScreen(
                                  courseId: widget.course.id,
                                  courseTitle: widget.course.title,
                                ),
                              ),
                            );
                          },
                        ),
                        const Gap(12),
                        _buildActionCard(
                          context,
                          icon: Icons.article,
                          label: "course.materials".tr(),
                          subtitle: 'Tap to show ',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MaterialsScreen(
                                  courseId: widget.course.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _showAddContentMenu(context);
                  },
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 4,
                  icon: Icon(Icons.add),
                  label: Text("course.add_content".tr()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).animate().scale(delay: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("course.delete_title".tr()),
          content: Text("course.delete_confirmation".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("common.cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context
                    .read<InstructorCoursesCubit>()
                    .DeleteCourse(CourseId: widget.course.id);
              },
              child: Text(
                "common.delete".tr(),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultImage() {
    return Image.asset(
      "assets/images/noimage.jpg",
      fit: BoxFit.cover,
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const Gap(12),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "course.options".tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(20),
              _buildAddOption(
                context,
                icon: Icons.video_collection,
                label: "course.new_video".tr(),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoUploadScreen(
                        id: widget.course.id,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 24),
              _buildAddOption(
                context,
                icon: Icons.insert_drive_file,
                label: "course.new_material".tr(),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileUploadScreen(
                        courseId: widget.course.id,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 24),
              _buildAddOption(
                context,
                icon: Icons.delete,
                label: "course.delete_course".tr(),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
