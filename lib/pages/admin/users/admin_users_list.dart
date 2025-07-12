import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/pages/auth/login.dart';
import '../admin_config.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import 'admin_users_form.dart';
import '../../../services/storage/user_storage.dart';
import '../../../models/user.dart';

class AdminUsersList extends StatefulWidget {
  const AdminUsersList({super.key});

  @override
  State<AdminUsersList> createState() => _AdminUsersListState();
}

class _AdminUsersListState extends State<AdminUsersList> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _checkUserAndLoad();
  }

  Future<void> _checkUserAndLoad() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    if (!userProvider.isLoggedIn || !userProvider.isAdmin) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

    // Si todo bien, cargar usuarios
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await getListUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _deleteUser(User user) async {
    try {
      await deleteUser(user);
      await _loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente')),
      );
    } catch (e) {
      // muestra mensaje si hubo un error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: $e')),
      );
    }
  }

  Future<void> _confirmDelete(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Estás seguro de eliminar a "${user.username}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Catálogo de Usuarios'),
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'config') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminConfigPage()),
                );
              } else if (value == 'logout') {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                await userProvider.logout();

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'config',
                child: Text('Configuración'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: _users.isEmpty
            ? const Center(child: Text('No hay usuarios registrados'))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user.username),
                      subtitle: Text('Usuario'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFF971c17),
                        ),
                        onPressed: () => _confirmDelete(user),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserFormPage(userToEdit: user),
                          ),
                        ).then((_) => _loadUsers()); // recargar al volver
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormPage()),
          );
        },
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
