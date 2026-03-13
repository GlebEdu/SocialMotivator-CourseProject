class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.balance = 1000,
    this.rating = 1000,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final double balance;
  final int rating;
}
