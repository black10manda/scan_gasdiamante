import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import 'auth/login.dart';
import 'package:lectura_gas_diamante/widgets/labeled_text_field.dart';
import 'package:lectura_gas_diamante/pages/readers/qr_scanner_page.dart';
import 'package:lectura_gas_diamante/services/api/api_service.dart';
import 'package:lectura_gas_diamante/services/data_storage.dart';
import 'package:lectura_gas_diamante/pages/readers/camera_page.dart';

class LecturaPage extends StatefulWidget {
  const LecturaPage({super.key});

  @override
  State<LecturaPage> createState() => _LecturaPageState();
}

class _LecturaPageState extends State<LecturaPage> {
  final TextEditingController _idClienteController = TextEditingController();
  final FocusNode _idClienteFocusNode = FocusNode();

  final TextEditingController _condominioController = TextEditingController();
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _codigoMedidorController =
      TextEditingController();

  String? _rutaFoto;

  @override
  void initState() {
    super.initState();

    _idClienteFocusNode.addListener(() {
      if (!_idClienteFocusNode.hasFocus) {
        final idCliente = int.tryParse(_idClienteController.text);
        if (idCliente != null) {
          _fetchClientePorId(idCliente);
        } else {
          setState(() {
            _clienteController.clear();
            _rfcController.clear();
            _condominioController.clear();
            _departamentoController.clear();
            _periodoController.clear();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _idClienteController.dispose();
    _idClienteFocusNode.dispose();
    _condominioController.dispose();
    _departamentoController.dispose();
    _clienteController.dispose();
    _rfcController.dispose();
    _periodoController.dispose();
    _codigoMedidorController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientePorId(int idCliente) async {
    _showLoadingDialog();

    try {
      final cliente = await ApiService.fetchClienteDetalle(idCliente);
      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        _clienteController.text = cliente?.clienteNombre ?? '';
        _rfcController.text = cliente?.rfc ?? '';
        _condominioController.text = cliente?.condominio ?? '';
        _departamentoController.text = cliente?.departamento ?? '';
        _periodoController.text = cliente?.periodo.toString() ?? '';
      });
    } catch (e) {
      if (mounted) Navigator.pop(context);

      final errorMsg = e.toString();
      if (errorMsg.contains('Sin conexión a internet')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Continuando sin conexión...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener datos del cliente')),
        );
      }
    }
  }

  Future<void> _abrirCamaraYProcesarFoto() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (result != null && context.mounted) {
      setState(() {
        _rutaFoto = result;
      });
    }
  }

  void _handleQrResult(String qrResult) async {
    final idCliente = int.tryParse(qrResult);
    if (idCliente == null) {
      _showErrorDialog('Código QR inválido');
      return;
    }

    final siNubeData = await getSiNubeData();
    if (siNubeData == null) {
      _showErrorDialog(
        'No hay configuración guardada. Contácte al administrador del sistema.',
      );
      return;
    }

    _showLoadingDialog();

    try {
      final cliente = await ApiService.fetchClienteDetalle(idCliente);
      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        _idClienteController.text = idCliente.toString();
        _clienteController.text = cliente?.clienteNombre ?? '';
        _rfcController.text = cliente?.rfc ?? '';
        _condominioController.text = cliente?.condominio ?? '';
        _departamentoController.text = cliente?.departamento ?? '';
        _periodoController.text = cliente?.periodo.toString() ?? '';
      });
    } catch (e) {
      if (mounted) Navigator.pop(context);
      final errorMsg = e.toString();
      if (errorMsg.contains('Sin conexión a internet')) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Continuando sin conexión...')),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener datos del cliente')),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      focusNode: _idClienteFocusNode,
                      isNumber: true,
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
                        onTap: _abrirCamaraYProcesarFoto,
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
              const SizedBox(height: 16),
              SizedBox(
                width: 80,
                height: 80,
                child: _rutaFoto == null
                    ? Image.asset(
                        'assets/images/tu_imagen_default.png',
                        fit: BoxFit.contain,
                      )
                    : Image.file(File(_rutaFoto!), fit: BoxFit.cover),
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
