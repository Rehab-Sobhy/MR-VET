import 'package:education_app/notifications/cubit.dart';
import 'package:education_app/notifications/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..fetchNotifications(id: ""),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationSuccess) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('No notifications found.'));
              }

              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    trailing: Text(notification.date),
                  );
                },
              );
            } else if (state is NotificationFailure) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
