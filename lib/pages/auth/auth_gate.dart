import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login.dart';
import '../registro_lectura/lectura.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoggedIn) {
      return const LecturaPage();
    } else {
      return const LoginPage();
    }
  }
}
