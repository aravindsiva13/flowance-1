// lib/presentation/widgets/notifications/notification_card.dart
import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/constants/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.notifications),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        onTap: onTap,
      ),
    );
  }
}