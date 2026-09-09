import '../models/notification_model.dart';

class DummyNotifications {
  static const List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'Achievement Unlocked!',
      message:
          'Congratulations! You completed your first waste scan and unlocked the First Scan achievement.',
      type: 'achievement',
      date: '08 Sep 2026',
      time: '10:30 AM',
      isRead: false,
    ),

    NotificationModel(
      id: '2',
      title: 'Scan Completed',
      message:
          'Your plastic bottle was identified with 94% confidence. It can be recycled.',
      type: 'scan',
      date: '07 Sep 2026',
      time: '10:32 AM',
      isRead: false,
    ),

    NotificationModel(
      id: '3',
      title: 'Great Recycling Progress!',
      message:
          'You have successfully completed 12 waste scans. Keep making a positive impact!',
      type: 'progress',
      date: '07 Sep 2026',
      time: '09:15 AM',
      isRead: true,
    ),

    NotificationModel(
      id: '4',
      title: 'Recycling Reminder',
      message:
          'Remember to separate recyclable materials from general household waste.',
      type: 'reminder',
      date: '06 Sep 2026',
      time: '06:00 PM',
      isRead: true,
    ),

    NotificationModel(
      id: '5',
      title: 'New Recycling Center',
      message:
          'A new recycling collection point has been added near your area.',
      type: 'location',
      date: '05 Sep 2026',
      time: '11:20 AM',
      isRead: false,
    ),

    NotificationModel(
      id: '6',
      title: 'E-Waste Reminder',
      message:
          'Batteries and electronic devices need special handling. Use an authorized e-waste collection center.',
      type: 'reminder',
      date: '04 Sep 2026',
      time: '04:45 PM',
      isRead: true,
    ),

    NotificationModel(
      id: '7',
      title: 'Eco Starter Unlocked!',
      message:
          'You completed 5 successful waste scans and unlocked the Eco Starter achievement.',
      type: 'achievement',
      date: '03 Sep 2026',
      time: '02:10 PM',
      isRead: true,
    ),

    NotificationModel(
      id: '8',
      title: 'Keep Recycling!',
      message:
          'You are only 2 successful scans away from unlocking the Recycling Rookie achievement.',
      type: 'progress',
      date: '02 Sep 2026',
      time: '08:30 AM',
      isRead: false,
    ),
  ];
}
