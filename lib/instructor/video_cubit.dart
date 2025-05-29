import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
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
        'https://e-learinng-production.up.railway.app/api/videos/add',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $auth',
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

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://e-learinng-production.up.railway.app/api/videos/course/$courseId',
        options: Options(headers: {
          'Authorization': 'Bearer $auth',
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
}
