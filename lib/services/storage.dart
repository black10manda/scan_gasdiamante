import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';

final storage = FlutterSecureStorage();

// Leer Usuarios
Future<List<User>> getUsers() async {
  final jsonString = await storage.read(key: 'users');
  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((e) => User.fromJson(e)).toList();
}

// Guardar Lista de Usuarios
Future<void> saveUsers(List<User> users) async {
  final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
  await storage.write(key: 'users', value: jsonString);
}

// Agregar Usuario
Future<void> addUser(User newone) async {
  final users = await getUsers();
  users.add(newone);
  await saveUsers(users);
}

Future<bool> validLogin(String username, String password) async {
  final users = await getUsers();
  return users.any(
    (user) => user.username == username && user.password == password,
  );
}

Future<void> initAdminUser() async {
  final users = await getUsers();
  if (users.isEmpty) {
    final adminUser = User(username: 'admin', password: 'admin123', type: 1);
    await addUser(adminUser);
  }
}
