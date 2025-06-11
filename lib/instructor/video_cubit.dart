import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/instructor/vidModel.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/instructor/video_dtates.dart';

class VideoUploadCubit extends Cubit<VideoUploadState> {
  VideoUploadCubit() : super(VideoUploadInitial());

  Future<void> uploadVideo({
    required String title,
    required String courseId,
    required File videoFile,
  }) async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    emit(VideoUploadLoading());

    try {
      print("🔄 بدء عملية رفع الفيديو");
      print("📌 العنوان: $title");
      print("📌 معرف الدورة: $courseId");
      print("📌 مسار ملف الفيديو: ${videoFile.path}");
      print("📦 حجم الفيديو: ${await videoFile.length()} بايت");

      final mimeType = lookupMimeType(videoFile.path);
      if (mimeType == null || !mimeType.startsWith('video/')) {
        emit(VideoUploadError('❌ الملف ليس من نوع فيديو مدعوم.'));
        return;
      }

      final splitMime = mimeType.split('/');
      final mediaType = MediaType(splitMime[0], splitMime[1]);

      final formData = FormData.fromMap({
        'title': title,
        'courseId': courseId,
        'video': await MultipartFile.fromFile(
          videoFile.path,
          filename: 'video.${splitMime[1]}',
          contentType: mediaType,
        ),
      });

      print("📤 FormData تم إنشاؤه وجاهز للإرسال...");

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));

      final response = await dio.post(
        'https://mrvet-production.up.railway.app/api/videos/add',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("✅ كود الاستجابة: ${response.statusCode}");
      print("📥 بيانات الاستجابة: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(VideoUploadSuccess());
      } else {
        emit(VideoUploadError('فشل في الرفع. الكود: ${response.statusCode}'));
      }
    } catch (e, stackTrace) {
      print("❗ استثناء أثناء الرفع: $e");
      print("📉 Stacktrace: $stackTrace");
      emit(VideoUploadError('حدث خطأ أثناء رفع الفيديو.'));
    }
  }

  Future<void> fetchVideosByCourse(String courseId) async {
    emit(VideoFetchLoading());
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://mrvet-production.up.railway.app/api/videos/course/$courseId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final videosJson = response.data['videos'] as List;
        final videos = videosJson.map((v) => VideoModel.fromJson(v)).toList();
        emit(VideoFetchSuccess(videos));
      } else {
        emit(VideoFetchError('فشل في جلب الفيديوهات'));
      }
    } catch (e) {
      emit(VideoFetchError('❌ خطأ أثناء جلب الفيديوهات: $e'));
      print('❌ خطأ أثناء جلب الفيديوهات: $e');
    }
  }

  Future<void> deleteVideo(String videoId, String courseId) async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    emit(VideoDeleteLoading());

    try {
      final dio = Dio();
      print('Sending DELETE request for video ID: $videoId');

      final response = await dio.delete(
        'https://mrvet-production.up.railway.app/api/courses/$courseId/videos/$videoId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      print('Response received:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Delete successful');
        emit(VideoDeleteSuccess());
        await fetchVideosByCourse(courseId);
      } else {
        print('Delete failed with status ${response.statusCode}');
        String errorMessage = 'Failed to delete video';

        if (response.data != null) {
          try {
            dynamic responseData = response.data;

            if (response.data is String) {
              print('Response is String, attempting to parse as JSON');
              responseData = jsonDecode(response.data);
            }

            if (responseData is Map) {
              errorMessage = responseData['message'] ??
                  responseData['error'] ??
                  errorMessage;
            } else if (responseData is String) {
              errorMessage = responseData;
            }

            print('Extracted error message: $errorMessage');
          } catch (e) {
            print('Error parsing response: $e');
            errorMessage = '${errorMessage} (Status: ${response.statusCode})';
          }
        }

        emit(VideoDeleteError(errorMessage));
        await fetchVideosByCourse(courseId);
      }
    } on DioException catch (e) {
      print('DioError occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response}');

      String errorMessage = 'Error deleting video';
      if (e.response != null) {
        print('Error response data: ${e.response!.data}');
        try {
          dynamic errorData = e.response!.data;

          if (e.response!.data is String) {
            errorData = jsonDecode(e.response!.data);
          }

          if (errorData is Map) {
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? e.message;
          }
        } catch (parseError) {
          print('Error parsing error response: $parseError');
          errorMessage = '${e.message} (Status: ${e.response?.statusCode})';
        }
      }

      emit(VideoDeleteError(errorMessage));
      await fetchVideosByCourse(courseId);
    } catch (e) {
      print('Unexpected error: $e');
      emit(VideoDeleteError('Unexpected error: ${e.toString()}'));
      await fetchVideosByCourse(courseId);
    }
  }
}
