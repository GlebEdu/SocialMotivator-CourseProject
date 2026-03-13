class Evidence {
  final String id;
  final String goalId;
  final String submittedByUserId;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? attachmentUrl;

  const Evidence({
    required this.id,
    required this.goalId,
    required this.submittedByUserId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.attachmentUrl,
  });
}
