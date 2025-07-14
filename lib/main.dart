import 'package:flutter/material.dart';
import 'pages/auth/login.dart';
import 'services/storage/user_storage.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/admin/users/admin_users_list.dart';
import 'pages/registro_lectura/lectura.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await initAdminUser();

  final userProvider = UserProvider();
  await userProvider.loadUser();

  runApp(
    ChangeNotifierProvider(create: (_) => userProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    Widget home;

    if (!userProvider.isLoggedIn) {
      home = const LoginPage();
    } else if (userProvider.isAdmin) {
      home = const AdminUsersList();
    } else {
      home = const LecturaPage();
    }

    return MaterialApp(
      title: 'Toma de Lectura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF971c17)),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF971c17)),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF971c17), // color del cursor en el TextField
          selectionColor: Color(0xFFc05b57),
          selectionHandleColor: Color(0xFF971c17),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF971c17),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}
