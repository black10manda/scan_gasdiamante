import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import 'auth/login.dart';
import 'package:lectura_gas_diamante/widgets/labeled_text_field.dart';
import 'package:lectura_gas_diamante/pages/readers/qr_scanner_page.dart';
import 'package:lectura_gas_diamante/services/api/api_service.dart';
import 'package:lectura_gas_diamante/services/data_storage.dart';

class LecturaPage extends StatefulWidget {
  const LecturaPage({super.key});

  @override
  State<LecturaPage> createState() => _LecturaPageState();
}

class _LecturaPageState extends State<LecturaPage> {
  final TextEditingController _idClienteController = TextEditingController();
  final TextEditingController _condominioController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _codigoMedidorController =
      TextEditingController();

  void _handleQrResult(String qrResult) async {
    final idCliente = int.tryParse(qrResult);
    if (idCliente == null) {
      _showErrorDialog('Código QR inválido');
    }

    final siNubeData = await getSiNubeData();
    if (siNubeData == null) {
      _showErrorDialog(
        'No hay configuración guardada. Contácte al administrador del sistema.',
      );
    }

    _showLoadingDialog();

    try {
      final clienteData = await ApiService.fetchClienteDetalle(idCliente);
      Navigator.pop(context);

      if (clienteData == null) {
        _showErrorDialog('No se encontró información del cliente.');
      } else {
        _showClienteData(clienteData);
        setState(() {
          _idClienteController.text = idCliente.toString();
        });
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Error al obtener datos: $e');
      return;
    }

    setState(() {
      _idClienteController.text = idCliente.toString();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showClienteData(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Datos del cliente'),
        content: Text(data.toString()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Asegura que el teclado no tape campos
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lectura'),
        centerTitle: true,
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'logout') {
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
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LabeledTextField(
                      label: 'ID Cliente',
                      controller: _idClienteController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QRScannerPage(),
                            ),
                          );

                          if (result != null &&
                              result is String &&
                              context.mounted) {
                            _handleQrResult(result);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/qr_reader.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: 'Condominio',
                controller: _condominioController,
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: 'Departamento',
                controller: _departamentoController,
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: 'Cliente',
                controller: _clienteController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: LabeledTextField(
                      label: 'RFC',
                      controller: _rfcController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: LabeledTextField(
                      label: 'Periodo',
                      controller: _periodoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: LabeledTextField(
                      label: 'Código del medidor',
                      controller: _codigoMedidorController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Material(
                      color: const Color(0xFF971c17),
                      child: InkWell(
                        onTap: () {},
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF971c17),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () => {},
              child: const Text(
                'Subir información',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
