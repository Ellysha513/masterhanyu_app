class UserProfile {
  final String id;
  final String username;
  final String email;

  String name;
  int age;
  String gender;
  String? imagePath; // avatar_url

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    this.imagePath,
  });
}
