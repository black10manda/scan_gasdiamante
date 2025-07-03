import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final storage = FlutterSecureStorage();

// Leer Usuarios
Future<List<User>> getUsers() async {
  final jsonString = await storage.read(key: 'users');
  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((e) => User.fromJson(e)).toList();
}

Future<List<User>> getListUsers() async {
  final jsonString = await storage.read(key: 'users');
  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);
  final allUsers = jsonList.map((e) => User.fromJson(e)).toList();

  final filteredUsers = allUsers.where((user) => user.type == 2).toList();

  return filteredUsers;
}

// Guardar Lista de Usuarios
Future<void> saveUsers(List<User> users) async {
  final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
  await storage.write(key: 'users', value: jsonString);
}

// Agregar Usuario
Future<void> addUser(User newUser) async {
  final users = await getUsers();

  final exists = users.any((u) => u.username == newUser.username);

  if (exists) {
    throw Exception('El nombre de usuario ya existe');
  }

  users.add(newUser);
  await saveUsers(users);
}

Future<bool> validLogin(String username, String password) async {
  final users = await getUsers();
  return users.any(
    (user) => user.username == username && user.password == password,
  );
}

Future<User?> getUserByLogin(String username, String password) async {
  final users = await getUsers();
  try {
    final matchedUser = users.firstWhere(
      (user) => user.username == username && user.password == password,
    );
    return User(
      username: matchedUser.username,
      password: '',
      type: matchedUser.type,
    );
  } catch (e) {
    return null;
  }
}

Future<void> initAdminUser() async {
  final users = await getUsers();
  if (users.isEmpty) {
    final adminUser = User(
      username: dotenv.env['ADMIN_USERNAME'] ?? 'defaultUser',
      password: dotenv.env['ADMIN_PASSWORD'] ?? 'defaultPass',
      type: 1,
    );
    await addUser(adminUser);
  }
}

Future<void> deleteUser(User userToDelete) async {
  final users = await getUsers();

  users.removeWhere(
    (u) => u.username == userToDelete.username && u.type == userToDelete.type,
  );

  await saveUsers(users);
}

Future<void> editUser(User updatedUser) async {
  final users = await getUsers();

  final index = users.indexWhere((u) => u.username == updatedUser.username);

  if (index == -1) {
    throw Exception('Usuario no encontrado');
  }

  users[index] = updatedUser;

  await saveUsers(users);
}
