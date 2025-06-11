import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:education_app/notifications/model.dart';
import 'package:education_app/notifications/states.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  Future<void> fetchNotifications(String id) async {
    emit(NotificationLoading());
    try {
      final response = await Dio().get(
          'https://e-learinng-production.up.railway.app/api/notifications/$id');
      final List data = response.data;

      final notifications =
          data.map((json) => NotificationModel.fromJson(json)).toList();
      emit(NotificationSuccess(notifications));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }
}
