class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      date: json['date'],
    );
  }
}
