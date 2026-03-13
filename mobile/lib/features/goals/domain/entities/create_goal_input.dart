class CreateGoalInput {
  final String title;
  final String description;
  final DateTime? deadline;

  const CreateGoalInput({
    required this.title,
    required this.description,
    this.deadline,
  });
}
