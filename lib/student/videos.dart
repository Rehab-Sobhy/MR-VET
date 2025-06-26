import 'package:education_app/instructor/playVideo.dart';
import 'package:education_app/instructor/vidModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/instructor/video_cubit.dart';
import 'package:education_app/instructor/video_dtates.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class StudentVideosScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const StudentVideosScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<StudentVideosScreen> createState() => _StudentVideosScreenState();
}

class _StudentVideosScreenState extends State<StudentVideosScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VideoUploadCubit>().fetchVideosByCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.courseTitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text('videos_screen.video_library'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => context
                .read<VideoUploadCubit>()
                .fetchVideosByCourse(widget.courseId),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
        child: BlocBuilder<VideoUploadCubit, VideoUploadState>(
          builder: (context, state) {
            if (state is VideoFetchLoading) {
              return _buildShimmerLoading();
            } else if (state is VideoFetchSuccess) {
              if (state.videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.video_remove,
                          size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('videos_screen.no_videos'.tr(),
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('videos_screen.add_first_video'.tr(),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                );
              }
              return _buildVideoList(state.videos);
            } else if (state is VideoFetchError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.warning_2, size: 50, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<VideoUploadCubit>()
                          .fetchVideosByCourse(widget.courseId),
                      child: Text('videos_screen.retry'.tr()),
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('videos_screen.loading_data'.tr()));
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoList(List<VideoModel> videos) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: videos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final video = videos[index];
        final thumbnailUrl = _getThumbnailUrl(video.videoPath);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final fullUrl =
                'https://mrvet-production.up.railway.app${video.videoPath}';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoUrl: fullUrl,
                  title: video.title,
                ),
              ),
            );
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: Container(
                    width: 120,
                    color: Colors.grey[200],
                    child: thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Iconsax.video, color: Colors.grey),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Iconsax.video, color: Colors.grey),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Iconsax.video,
                                size: 30, color: Colors.grey),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          video.title,
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
                            const Icon(Iconsax.clock,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration('00:00'),
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child:
                      Icon(Iconsax.arrow_left_2, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _getThumbnailUrl(String videoPath) {
    return null;
  }

  String _formatDuration(String duration) {
    return duration;
  }
}
