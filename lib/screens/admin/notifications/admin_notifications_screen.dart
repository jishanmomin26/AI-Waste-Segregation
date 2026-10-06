import 'package:flutter/material.dart';

import '../../../data/dummy_notifications.dart';
import '../../../models/notification_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String _selectedFilter = 'All';

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'Unread') {
      return DummyNotifications.notifications
          .where((notification) => notification.isUnread)
          .toList();
    }

    return DummyNotifications.notifications;
  }

  int get _unreadCount {
    return DummyNotifications.notifications
        .where((notification) => notification.isUnread)
        .length;
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
            _buildFilterBar(),

            Expanded(
              child:
                  notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          return _buildNotificationTile(notification);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _filterChip(
              title: 'All',
              count: DummyNotifications.notifications.length,
              selected: _selectedFilter == 'All',
              onTap: () {
                setState(() {
                  _selectedFilter = 'All';
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _filterChip(
              title: 'Unread',
              count: _unreadCount,
              selected: _selectedFilter == 'Unread',
              onTap: () {
                setState(() {
                  _selectedFilter = 'Unread';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String title,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    final icon = _getNotificationIcon(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await _showDeleteConfirmation();
      },
      onDismissed: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification removed in demo mode.')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:
              notification.isUnread
                  ? AppColors.primaryLight
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                notification.isUnread
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    notification.isUnread
                        ? AppColors.primary
                        : AppColors.background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: notification.isUnread ? Colors.white : AppColors.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

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
                          margin: const EdgeInsets.only(top: 5, left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(notification.message, style: AppTextStyles.bodySmall),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Text(notification.date, style: AppTextStyles.labelSmall),
                      const SizedBox(width: 8),
                      Text('•', style: AppTextStyles.labelSmall),
                      const SizedBox(width: 8),
                      Text(notification.time, style: AppTextStyles.labelSmall),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'read') {
                  _markAsRead(notification);
                } else if (value == 'delete') {
                  _showDeleteMessage();
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'read',
                    child: Row(
                      children: [
                        Icon(Icons.done_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Mark as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
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
        return Icons.notifications_active_outlined;

      case 'location':
        return Icons.location_on_outlined;

      case 'ewaste':
        return Icons.battery_alert_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No unread notifications',
              style: AppTextStyles.heading3,
            ),

            const SizedBox(height: 7),

            const Text(
              'You are all caught up. New notifications will appear here.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _markAsRead(NotificationModel notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${notification.title}" marked as read in demo mode.'),
      ),
    );
  }

  void _markAllAsRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read in demo mode.'),
      ),
    );
  }

  void _showDeleteMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted in demo mode.')),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text(
            'Are you sure you want to remove this notification?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
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
}
