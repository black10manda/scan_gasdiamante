import 'package:flutter/material.dart';
import '../../services/storage.dart';
import '../admin/admin_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../home.dart';
import 'package:lectura_gas_diamante/widgets/password_text_field.dart';
// import '../../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> _login() async {
    final user = _userController.text;
    final pass = _passController.text;

    final userValid = await getUserByLogin(user, pass);

    if (!mounted) return;

    if (userValid != null && userValid.type == 2) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(userValid);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

      return;
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Acceso denegado'),
          content: Text('Contraseña o usuario incorrecto.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
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
      backgroundColor: Colors.white,
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
              PasswordTextField(controller: _passController),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: _login,
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminAuth()),
                    );
                  },
                  child: const Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
