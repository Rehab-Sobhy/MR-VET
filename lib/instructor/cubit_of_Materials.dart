import 'dart:io';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/instructor/materialstates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class MaterialsCubit extends Cubit<MaterialsState> {
  final Dio _dio = Dio();

  MaterialsCubit() : super(MaterialsInitial());

  Future<void> uploadPdfFile({
    required String courseId,
    required File file,
  }) async {
    emit(FileUploadLoading(0.0));

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        contentType: MediaType('application', 'pdf'),
      ),
    });
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final response = await _dio.post(
        'https://mrvet-production.up.railway.app/api/materials/$courseId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (int sent, int total) {
          double progress = sent / total;
          emit(FileUploadLoading(progress));
        },
      );

      emit(FileUploadSuccess(response.data));
      print('✅ Success: ${response.statusCode}');
      // Refresh materials after upload
      await fetchMaterials(courseId);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data.toString() ?? e.message ?? "Unknown error";
      emit(FileUploadFailure(errorMessage));
      print('❌ Error: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
    }
  }

  Future<void> fetchMaterials(String courseId) async {
    emit(MaterialsLoading());
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final response = await _dio.get(
        'https://mrvet-production.up.railway.app/api/materials/$courseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final materials = response.data['materials'];
      emit(MaterialsSuccess(materials));
    } on DioException catch (e) {
      emit(MaterialsFailure('فشل تحميل المواد'));
      print('❌ Error fetching materials: ${e.message}');
    }
  }

  Future<void> downloadFile(
    String url,
    String fileName, {
    required BuildContext context,
  }) async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();

    if (token == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في تحميل الملف. الرجاء المحاولة لاحقًا.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (state is! MaterialsSuccess) return;

    final successState = state as MaterialsSuccess;
    var progressMap = Map<String, double>.from(successState.downloadProgress);

    try {
      progressMap[url] = 0.0;
      emit(successState.copyWith(downloadProgress: progressMap));

      // 🔐 Get app-internal directory
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$fileName';

      print('⬇️ Starting download...');
      print('🔗 URL: $url');
      print('📁 Save Path: $savePath');
      print('🔐 Authorization: Bearer $token');

      final response = await _dio.download(
        url,
        savePath,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            progressMap[url] = progress;
            emit(successState.copyWith(downloadProgress: progressMap));
          }
        },
      );

      progressMap.remove(url);
      emit(successState.copyWith(downloadProgress: progressMap));

      print('✅ Download complete!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحميل الملف بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      progressMap.remove(url);
      emit(successState.copyWith(downloadProgress: progressMap));

      print('❌ Error downloading file: ${e.message}');
      String errorMessage = 'فشل تحميل الملف. الرجاء المحاولة لاحقًا.';
      if (e.response?.statusCode == 404) {
        errorMessage = 'الملف غير موجود. تأكد من الرابط أو تواصل مع الدعم.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      rethrow;
    } catch (e) {
      progressMap.remove(url);
      emit(successState.copyWith(downloadProgress: progressMap));

      print('❗ Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع أثناء تحميل الملف.'),
          backgroundColor: Colors.red,
        ),
      );

      rethrow;
    }
  }

  String getFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    if (extension == 'pdf') return 'pdf';

    if (['doc', 'docx'].contains(extension)) return 'word';
    if (['ppt', 'pptx'].contains(extension)) return 'powerpoint';
    if (['xls', 'xlsx'].contains(extension)) return 'excel';
    if (['zip', 'rar'].contains(extension)) return 'archive';
    return 'file';
  }

  Future<void> DeleteMaterial(
      {required String materialId, required courseId}) async {
    emit(DeleteMaterialLoading());
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      final response = await _dio.delete(
        "$baseUrlKey/api/materials/$materialId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print('✅ Response: ${response.statusCode}');
      print('✅ Data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeleteMaterialSuccess());
        fetchMaterials(courseId);
      } else {
        emit(DeleteMaterialfiled());
      }
    } catch (e) {
      print('❌ DioException: $e');
      emit(DeleteMaterialfiled());
    }
  }
}
