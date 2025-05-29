import 'package:education_app/instructor/vidModel.dart';

abstract class VideoUploadState {}

class VideoUploadInitial extends VideoUploadState {}

class VideoUploadLoading extends VideoUploadState {}

class VideoUploadSuccess extends VideoUploadState {}

class VideoUploadError extends VideoUploadState {
  final String message;

  VideoUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

// 📥 States for fetching videos
class VideoFetchLoading extends VideoUploadState {}

class VideoFetchSuccess extends VideoUploadState {
  final List<VideoModel> videos;

  VideoFetchSuccess(this.videos);

  @override
  List<Object?> get props => [videos];
}

class VideoFetchError extends VideoUploadState {
  final String message;

  VideoFetchError(this.message);

  @override
  List<Object?> get props => [message];
}
