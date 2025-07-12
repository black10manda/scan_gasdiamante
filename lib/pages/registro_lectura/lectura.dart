import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/models/cliente.dart';
import 'package:lectura_gas_diamante/models/registro_lectura_offline.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../auth/login.dart';
import 'package:lectura_gas_diamante/widgets/labeled_text_field.dart';
import 'package:lectura_gas_diamante/pages/readers/qr_scanner_page.dart';
import 'package:lectura_gas_diamante/services/api/api_service.dart';
import 'package:lectura_gas_diamante/services/storage/data_storage.dart';
import 'package:lectura_gas_diamante/services/storage/lectura_offline_storage.dart';
import 'package:lectura_gas_diamante/pages/readers/camera_text_recognizer_page.dart';
import 'package:lectura_gas_diamante/pages/registro_lectura/no_internet/no_internet_list.dart';
import 'package:lectura_gas_diamante/models/registro_lectura.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';

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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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

  Future<bool> _verificarConexion() async {
    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> _guardarFoto(File imagen) async {
    final nombreArchivo = '${_idClienteController.text}_imagen.jpg';
    final appDocDir = await getApplicationDocumentsDirectory();
    final permanentFile = File('${appDocDir.path}/$nombreArchivo');

    final savedFile = await imagen.copy(permanentFile.path);
    return savedFile.path;
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
    if (_idClienteController.text.trim().isNotEmpty) {
      final result = await Navigator.push<Map<String, String>>(
        context,
        MaterialPageRoute(builder: (_) => const CameraTextRecognizerPage()),
      );

      if (result != null && context.mounted) {
        setState(() {
          _codigoMedidorController.text = result['codigoTexto'] ?? '';
          _rutaFoto = result['rutaImagen'];
        });
      }
    } else {
      _showErrorDialog('Primero debes escánear el código QR.');
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

    _idClienteController.text = idCliente.toString();
  }

  void _limpiarCampos() {
    _idClienteController.clear();
    _condominioController.clear();
    _departamentoController.clear();
    _clienteController.clear();
    _rfcController.clear();
    _periodoController.clear();
    _codigoMedidorController.clear();

    _rutaFoto = null;

    setState(() {});
  }

  Future<void> _subirInformacion() async {
    final isConnected = await _verificarConexion();

    if (!isConnected) {
      _showLoadingDialog();
      if (_rutaFoto != null) {
        final imagenTemporal = File(_rutaFoto!);
        final rutaPermanente = await _guardarFoto(imagenTemporal);

        final cliente = Cliente(
          idCliente: int.tryParse(_idClienteController.text) ?? 0,
          clienteNombre: _clienteController.text,
          rfc: _rfcController.text,
          condominio: _condominioController.text,
          departamento: _departamentoController.text,
          periodo: int.tryParse(_periodoController.text) ?? 0,
          lectura: _codigoMedidorController.text,
        );

        final lecturaOffline = RegistroLecturaOffline(
          cliente: cliente,
          imagenMedidor: rutaPermanente,
          estatus: 0,
        );

        try {
          await agregarLecturaOffline(lecturaOffline);

          if (!mounted) return;
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AlertDialog(
              title: Text('Registro guardado correctamente'),
              content: Text(
                'El registro sin internet ha sido guardado correctamente para su posterior subida.',
              ),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 800));

          if (!mounted) return;
          Navigator.pop(context);

          _limpiarCampos();
        } catch (e) {
          if (mounted) Navigator.pop(context);
          _showErrorDialog('Error al guardar registro offline_ $e');
        }
      }
    } else {
      final validar = _validarCampos();
      if (!validar) return;

      _showLoadingDialog();

      final cliente = Cliente(
        idCliente: int.tryParse(_idClienteController.text)!,
        clienteNombre: _clienteController.text,
        rfc: _rfcController.text,
        condominio: _condominioController.text,
        departamento: _departamentoController.text,
        periodo: int.tryParse(_periodoController.text)!,
        lectura: _codigoMedidorController.text,
      );

      try {
        final bytes = await File(_rutaFoto!).readAsBytes();

        final registro = RegistroLectura(
          cliente: cliente,
          imagenMedidor: bytes,
        );

        final enviado = await ApiService.enviarLectura(registro);

        if (!mounted) return;
        Navigator.pop(context);

        if (enviado) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AlertDialog(
              title: Text('Éxito'),
              content: Text('La lectura fue enviada correctamente.'),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 800));

          if (!mounted) return;
          Navigator.pop(context);
          _limpiarCampos();
        } else {
          _showErrorDialog('No se pudo enviar la lectura.');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        _showErrorDialog('Error al enviar lectura: $e');
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

  bool _validarCampos() {
    final camposRequeridos = {
      _idClienteController.text.trim(): 'ID Cliente',
      _condominioController.text.trim(): 'Condominio',
      _departamentoController.text.trim(): 'Departamento',
      _clienteController.text.trim(): 'Cliente',
      _rfcController.text.trim(): 'RFC',
      _periodoController.text.trim(): 'Periodo',
      _codigoMedidorController.text.trim(): 'Lectura',
    };

    for (final entry in camposRequeridos.entries) {
      if (entry.key.isEmpty) {
        _mostrarError('El campo "${entry.value}" es obligatorio');
        return false;
      }
    }

    if (_rutaFoto == null || _rutaFoto!.isEmpty) {
      _mostrarError('Debes tomar una foto del medidor');
      return false;
    }

    return true;
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
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
                height: 200,
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
              onPressed: _subirInformacion,
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoInternetListPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Subir información',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: const [
                      Icon(Icons.cloud, size: 48, color: Colors.white),
                      Icon(Icons.check, size: 32, color: Color(0xFF971c17)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
