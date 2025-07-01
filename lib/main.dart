import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'services/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAdminUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
