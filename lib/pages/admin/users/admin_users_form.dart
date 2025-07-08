import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_storage.dart';
import 'admin_users_list.dart';
import 'package:lectura_gas_diamante/widgets/password_text_field.dart';
import 'package:lectura_gas_diamante/widgets/labeled_text_field.dart';

class UserFormPage extends StatefulWidget {
  final User? userToEdit;

  const UserFormPage({super.key, this.userToEdit});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.userToEdit != null;

    if (isEditing) {
      _userController.text = widget.userToEdit!.username;
      _passController.text = '';
    }
  }

  Future<void> _saveUser() async {
    final user = _userController.text;
    final pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      _showMessage('Usuario y contraseña son obligatorios');
      return;
    }

    try {
      if (isEditing) {
        final editedUser = User(
          username: user,
          password: pass.isNotEmpty ? pass : widget.userToEdit!.password,
          type: widget.userToEdit!.type,
        );
        await editUser(editedUser);
      } else {
        final newUser = User(username: user, password: pass, type: 2);
        await addUser(newUser);
      }
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('Usuario guardado correctamente'),
          content: Text('Redirigiendo...'),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminUsersList()),
      );
    } catch (e) {
      _showMessage('Error al guardar el usuario: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Agregar Usuario'),
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SizedBox(
          width: 300, // Puedes ajustar este valor según tu diseño
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LabeledTextField(
                label: 'Usuario',
                controller: _userController,
                enabled: !isEditing,
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
                  onPressed: _saveUser,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
