class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String date;
  final String time;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    required this.time,
    required this.isRead,
  });

  bool get isUnread => !isRead;
}
