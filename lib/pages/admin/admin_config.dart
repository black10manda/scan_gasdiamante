import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/widgets/password_text_field.dart';

class AdminConfigPage extends StatefulWidget {
  const AdminConfigPage({super.key});

  @override
  State<AdminConfigPage> createState() => _AdminConfigPageState();
}

class _AdminConfigPageState extends State<AdminConfigPage> {
  final TextEditingController _passController = TextEditingController();

  double _calidadValue = 50;
  double _tamanoValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configuración de Administrador'),
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Datos de conexión a sinube',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Empresa:',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Sucursal:',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Usuario:',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              PasswordTextField(controller: _passController),
              const SizedBox(height: 32),
              Text(
                'Fotografía',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Calidad:'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      value: _calidadValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${_calidadValue.round()}',
                      onChanged: (double newValue) {
                        setState(() {
                          _calidadValue = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Tamaño:'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      value: _tamanoValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${_tamanoValue.round()}',
                      onChanged: (double newValue) {
                        setState(() {
                          _tamanoValue = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF971c17),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                // lógica de ingreso
              },
              child: const Text('Guardar'),
            ),
          ),
        ),
      ),
    );
  }
}
