class User {
  final String username;
  final String password;
  final int type;

  User({required this.username, required this.password, required this.type});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'type': type,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'],
    password: json['password'],
    type: json['type'],
  );
}
