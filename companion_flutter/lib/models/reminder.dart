class Reminder {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final DateTime dueAt;
  final String type;
  final bool isRecurring;
  final String status;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueAt,
    required this.type,
    required this.isRecurring,
    required this.status,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueAt: DateTime.parse(json['due_at'] as String),
        type: json['type'] as String,
        isRecurring: json['is_recurring'] as bool,
        status: json['status'] as String,
      );
}
