import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../widgets/reminder_card.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ApiService.getReminders();
      if (mounted) {
        setState(() => _items = list);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addDialog() async {
    final titleCtrl = TextEditingController();
    DateTime? due;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: DateTime(now.year + 5),
                      initialDate: now,
                    );
                    if (date == null) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time == null) return;

                    final picked = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );

                    if (picked.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a future time')),
                      );
                      return;
                    }

                    due = picked;
                    setStateDialog(() {});
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    due == null
                        ? 'Pick date & time'
                        : DateFormat('dd MMM yyyy, HH:mm').format(due!),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty || due == null) return;

                  try {
                    final newReminder = await ApiService.addReminder(
                      userId: ApiService.userId!,
                      title: titleCtrl.text.trim(),
                      dueAt: due!,
                      description: null,
                    );

                    try {
                      await NotificationService.schedule(
                        titleCtrl.text.trim(),
                        "Your reminder is due!",
                        due!,
                        id: due!.millisecondsSinceEpoch % 100000,
                      );
                    } catch (_) {
                      debugPrint("Notification scheduling failed (permission issue)");
                    }

                    if (mounted) {
                      setState(() {
                        _items.insert(0, newReminder);
                      });
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteReminder(int id) async {
    try {
      await ApiService.deleteReminder(id);
      await NotificationService.cancelNotification(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final r = _items[i];
                  final reminderId = r['id'] as int;
                  return ReminderCard(
                    title: r['title'] as String,
                    dueAt: DateTime.parse(r['due_at'] as String),
                    type: r['type'] as String,
                    onDelete: () => _deleteReminder(reminderId),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
