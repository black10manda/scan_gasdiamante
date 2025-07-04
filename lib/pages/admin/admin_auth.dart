import 'package:flutter/material.dart';
import '../../services/storage.dart';
import 'users/admin_users_list.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:lectura_gas_diamante/widgets/password_text_field.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminAuth extends StatefulWidget {
  const AdminAuth({super.key});

  @override
  State<AdminAuth> createState() => _AdminAuthState();
}

class _AdminAuthState extends State<AdminAuth> {
  final TextEditingController _passController = TextEditingController();

  Future<void> _auth() async {
    final pass = _passController.text;
    final username = dotenv.env['ADMIN_USERNAME'] ?? 'admin';
    final user = await getUserByLogin(username, pass);

    if (!mounted) return;

    if (user != null && user.type == 1) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(user);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('Acceso correcto'),
          content: Text('Redirigiendo...'),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminUsersList()),
      );
      return;
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Acceso denegado'),
          content: const Text('Contraseña incorrecta o no es administrador.'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Acceso de Administrador'),
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PasswordTextField(controller: _passController),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _auth,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
