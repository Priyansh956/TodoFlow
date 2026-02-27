class AppUser {
  final String uid;
  final String name;
  final String email;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
  };
}