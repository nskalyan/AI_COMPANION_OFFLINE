import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final DateTime dueAt;
  final String type;
  final VoidCallback? onDelete; // delete handler

  const ReminderCard({
    super.key,
    required this.title,
    required this.dueAt,
    required this.type,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.alarm),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${DateFormat('EEE, dd MMM yyyy – HH:mm').format(dueAt)} • $type',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
