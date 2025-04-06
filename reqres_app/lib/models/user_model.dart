class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
  }) {
    return User(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }
}
