import 'goal_status.dart';

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? deadline;

    const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.deadline,
  });
}
