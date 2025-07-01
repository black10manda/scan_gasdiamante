import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscurePassword = true;

  void _login() {
    final user = _userController.text;
    final pass = _passController.text;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login'),
        content: Text('Usuario: $user\nContraseña: $pass'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_gas_diamante.jpg',
                width: 500,
                height: 500,
              ),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuario:',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña:',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _login, child: const Text('Ingresar')),
            ],
          ),
        ),
      ),
    );
  }
}
