import '../../../goals/data/models/goal_model.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../domain/entities/user.dart';

class ProfileSummaryModel {
  const ProfileSummaryModel({
    required this.user,
    required this.goals,
    required this.totalGoals,
    required this.completedGoals,
    required this.activeGoals,
    required this.resolvedGoals,
    required this.completionRate,
    required this.completionRateLabel,
  });

  factory ProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    return ProfileSummaryModel(
      user: User(
        id: userJson['id'] as String,
        email: userJson['email'] as String? ?? '',
        displayName: userJson['displayName'] as String,
        avatarUrl: userJson['avatarUrl'] as String?,
        balance: (userJson['balance'] as num?)?.toDouble() ?? 0,
        rating: (userJson['rating'] as num?)?.toInt() ?? 0,
      ),
      goals: ((json['goals'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .map((data) {
            data['userId'] = data['userId'] ?? userJson['id'];
            return GoalModel.fromJson(data).toEntity();
          })
          .toList(growable: false),
      totalGoals: (json['totalGoals'] as num).toInt(),
      completedGoals: (json['completedGoals'] as num).toInt(),
      activeGoals: (json['activeGoals'] as num).toInt(),
      resolvedGoals: (json['resolvedGoals'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      completionRateLabel: json['completionRateLabel'] as String,
    );
  }

  final User user;
  final List<Goal> goals;
  final int totalGoals;
  final int completedGoals;
  final int activeGoals;
  final int resolvedGoals;
  final double completionRate;
  final String completionRateLabel;
}
