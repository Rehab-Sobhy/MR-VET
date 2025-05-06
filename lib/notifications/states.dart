import 'package:education_app/notifications/model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationSuccess(this.notifications);
}

class NotificationFailure extends NotificationState {
  final String error;

  NotificationFailure(this.error);
}
