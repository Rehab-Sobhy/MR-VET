class VideoModel {
  final String id;
  final String title;
  final String videoPath;
  final String courseId;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoPath,
    required this.courseId,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['_id'],
      title: json['title'],
      videoPath: json['videoPath'],
      courseId: json['courseId'],
    );
  }
}
