import 'package:flutter/material.dart';

import '../../../data/dummy_notifications.dart';
import '../../../models/notification_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<NotificationModel>.from(
      DummyNotifications.notifications,
    );
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'Unread') {
      return _notifications
          .where((notification) => notification.isUnread)
          .toList();
    }

    return _notifications;
  }

  int get _unreadCount {
    return _notifications.where((notification) => notification.isUnread).length;
  }

  void _markAsRead(int index) {
    final notification = _notifications[index];

    setState(() {
      _notifications[index] = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        date: notification.date,
        time: notification.time,
        isRead: true,
      );
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications =
          _notifications.map((notification) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              date: notification.date,
              time: notification.time,
              isRead: true,
            );
          }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  void _deleteNotification(int index) {
    final notification = _notifications[index];

    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notification.title} removed.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _notifications.insert(
                index.clamp(0, _notifications.length),
                notification,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Read all'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummary(),

            const SizedBox(height: 12),

            SizedBox(
              height: 42,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [_buildFilterChip('All'), _buildFilterChip('Unread')],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child:
                  notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          final actualIndex = _notifications.indexWhere(
                            (item) => item.id == notification.id,
                          );

                          return _buildNotificationCard(
                            notification,
                            actualIndex,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Notifications',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  _unreadCount == 0
                      ? 'You are all caught up!'
                      : '$_unreadCount unread notification'
                          '${_unreadCount == 1 ? '' : 's'}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppColors.primaryLight,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    int actualIndex,
  ) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await _showDeleteConfirmation(notification);
      },
      onDismissed: (_) {
        _deleteNotification(actualIndex);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color:
            notification.isUnread ? AppColors.primaryLight : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color:
                notification.isUnread
                    ? AppColors.primary.withValues(alpha: 0.20)
                    : AppColors.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: notification.isUnread ? () => _markAsRead(actualIndex) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(
                  notification.type,
                  notification.isUnread,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.titleSmall,
                            ),
                          ),
                          if (notification.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 5, left: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        notification.message,
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(notification.date, style: AppTextStyles.caption),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(notification.time, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'read') {
                      _markAsRead(actualIndex);
                    } else if (value == 'delete') {
                      _confirmDelete(notification, actualIndex);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (notification.isUnread)
                          const PopupMenuItem<String>(
                            value: 'read',
                            child: Row(
                              children: [
                                Icon(Icons.done_outlined, size: 19),
                                SizedBox(width: 10),
                                Text('Mark as read'),
                              ],
                            ),
                          ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 19),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, bool unread) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: unread ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        _getNotificationIcon(type),
        color: AppColors.primary,
        size: 23,
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
        return Icons.emoji_events_outlined;

      case 'scan':
        return Icons.document_scanner_outlined;

      case 'progress':
        return Icons.trending_up_rounded;

      case 'reminder':
        return Icons.alarm_outlined;

      case 'location':
        return Icons.location_on_outlined;

      case 'ewaste':
        return Icons.battery_alert_outlined;

      case 'tip':
        return Icons.lightbulb_outline_rounded;

      default:
        return Icons.notifications_outlined;
    }
  }

  Widget _buildEmptyState() {
    final isUnreadFilter = _selectedFilter == 'Unread';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUnreadFilter ? 'No unread notifications' : 'No notifications',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isUnreadFilter
                  ? 'You are all caught up!'
                  : 'New notifications will appear here.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(NotificationModel notification) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: Text(
            'Remove "${notification.title}" from your notifications?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _confirmDelete(NotificationModel notification, int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: Text(
            'Remove "${notification.title}" from your notifications?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _deleteNotification(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
