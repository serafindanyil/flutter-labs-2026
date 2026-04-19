class UserModel {
  final String name;
  final String email;
  final String password;

  const UserModel({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password};
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  UserModel copyWith({String? name, String? email, String? password}) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
