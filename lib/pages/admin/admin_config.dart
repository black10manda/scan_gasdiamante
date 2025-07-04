import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/pages/admin/users/admin_users_list.dart';
import 'package:lectura_gas_diamante/widgets/password_text_field.dart';
import '../../services/data_storage.dart';
import '../../models/sinube_data.dart';

class AdminConfigPage extends StatefulWidget {
  const AdminConfigPage({super.key});

  @override
  State<AdminConfigPage> createState() => _AdminConfigPageState();
}

class _AdminConfigPageState extends State<AdminConfigPage> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();

  double _calidadValue = 50;
  double _tamanoValue = 50;

  @override
  void initState() {
    super.initState();
    _loadSiNubeData();
  }

  Future<void> _loadSiNubeData() async {
    final savedData = await getSiNubeData();
    if (savedData != null) {
      _empresaController.text = savedData.empresa;
      _sucursalController.text = savedData.sucursal;
      _usuarioController.text = savedData.usuario;
      _passController.text = savedData.password;
      setState(() {
        _calidadValue = savedData.calidad.toDouble();
        _tamanoValue = savedData.tamano.toDouble();
      });
    }
  }

  Future<void> _saveConfig() async {
    final empresa = _empresaController.text;
    final sucursal = _sucursalController.text;
    final usuario = _usuarioController.text;
    final password = _passController.text;

    int calidad = _calidadValue.round();
    int tamano = _tamanoValue.round();

    final newData = SiNubeData(
      empresa: empresa,
      sucursal: sucursal,
      usuario: usuario,
      password: password,
      calidad: calidad,
      tamano: tamano,
    );

    try {
      await saveSiNubeData(newData);
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('Datos guardados correctamente'),
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
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la configuración: $e')),
      );
      return;
    }
  }

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
                controller: _empresaController,
                decoration: const InputDecoration(
                  labelText: 'Empresa:',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sucursalController,
                decoration: const InputDecoration(
                  labelText: 'Sucursal:',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usuarioController,
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
                  Text('Calidad: ${_calidadValue.round()} %'),
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
                  Text('Tamaño: ${_tamanoValue.round()} %'),
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
              onPressed: () => _saveConfig(),
              child: const Text('Guardar'),
            ),
          ),
        ),
      ),
    );
  }
}
