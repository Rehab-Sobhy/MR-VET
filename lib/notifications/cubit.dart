import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/notifications/model.dart';
import 'package:education_app/notifications/states.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final Dio dio = Dio();

  NotificationCubit() : super(NotificationInitial()) {
    dio.options.headers = {'Content-Type': 'application/json'};
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<void> loadNotifications() async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    emit(NotificationLoading());
    try {
      final response = await dio.get(
        '$baseUrlKey/api/notifications/my',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print('--- Notifications API Response ---');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      print('----------------------------------');

      final notificationsResponse =
          NotificationsResponse.fromJson(response.data);

      print(
          "Parsed ${notificationsResponse.notifications.length} notifications.");

      final unreadCount =
          notificationsResponse.notifications.where((n) => !n.read).length;

      emit(NotificationLoaded(
        notifications: notificationsResponse.notifications,
        unreadCount: unreadCount,
      ));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ??
          'Failed to load notifications: ${e.message}';
      print('Dio error: $errorMessage');
      emit(NotificationError(errorMessage));
    } catch (e) {
      print('Unexpected error: ${e.toString()}');
      emit(NotificationError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final authService = AuthServiceClass();
    final token = await authService.getToken();
    try {
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;

        final updatedNotifications = currentState.notifications.map((n) {
          return n.id == notificationId && !n.read ? n.copyWith(read: true) : n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.read).length;

        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));

        final response = await dio.put(
          '$baseUrlKey/api/notifications/$notificationId',
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          ),
        );

        // Print the full response data for debugging
        print('Mark as read response: ${response.data}');

        emit(NotificationMarkedAsRead(notificationId));
      }
    } on DioException catch (e) {
      // Log full error response for debugging
      print('DioException occurred: ${e.message}');
      print('Response data: ${e.response?.data}');

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      }

      // Handle different data types gracefully
      final errorData = e.response?.data;
      String errorMessage;

      if (errorData is Map && errorData['message'] != null) {
        errorMessage = errorData['message'];
      } else if (errorData is String) {
        errorMessage = errorData;
      } else {
        errorMessage = 'فشل في تحديث حالة الإشعار: ${e.message}';
      }

      emit(NotificationError(errorMessage));
    } catch (e) {
      print('Unexpected error: $e');
      emit(NotificationError('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}
