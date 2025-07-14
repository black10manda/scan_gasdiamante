import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/pages/registro_lectura/no_internet/sections/lecturas_pendientes.dart';
import 'package:lectura_gas_diamante/pages/registro_lectura/no_internet/sections/lecturas_enviadas.dart';
import 'package:lectura_gas_diamante/pages/registro_lectura/no_internet/sections/lecturas_todas.dart';
import 'package:lectura_gas_diamante/services/storage/lectura_offline_storage.dart';
import 'package:lectura_gas_diamante/services/api/api_service.dart';
import 'package:lectura_gas_diamante/models/registro_lectura_offline.dart';
import 'package:lectura_gas_diamante/models/registro_lectura.dart';
import 'package:lectura_gas_diamante/models/cliente.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:io';

class NoInternetListPage extends StatefulWidget {
  const NoInternetListPage({super.key});

  @override
  State<NoInternetListPage> createState() => _NoInternetListPageState();
}

class _NoInternetListPageState extends State<NoInternetListPage>
    with SingleTickerProviderStateMixin {
  Key _keyPendientes = UniqueKey();
  Key _keyEnviadas = UniqueKey();
  Key _keyTodas = UniqueKey();

  Future<void> _obtenerInfFaltante() async {
    _showLoadingDialog();

    final hasInternet = await _verificarConexion();
    if (!hasInternet) {
      _showErrorDialog('Aún no hay conexión a internet');
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final lecturasOffline = await cargarLecturasPendientesOffline();
    bool exito = true;

    for (final registro in lecturasOffline) {
      final int idCliente = registro.cliente.idCliente;

      try {
        final clienteNuevo = await ApiService.fetchClienteDetalle(idCliente);

        if (clienteNuevo != null) {
          final clienteActualizado = Cliente(
            periodo: clienteNuevo.periodo,
            idCliente: clienteNuevo.idCliente,
            condominio: clienteNuevo.condominio,
            departamento: clienteNuevo.departamento,
            rfc: clienteNuevo.rfc,
            clienteNombre: clienteNuevo.clienteNombre,
            lectura: registro.cliente.lectura,
          );

          final lecturaActualizada = RegistroLecturaOffline(
            cliente: clienteActualizado,
            imagenMedidor: registro.imagenMedidor,
            estatus: 1,
          );

          try {
            await editarLecturaOffline(lecturaActualizada);
          } catch (e) {
            exito = false;
            _showErrorDialog('Hubo un error al actualizar un registro: $e');
          }
        }
      } catch (e) {
        exito = false;
        _showErrorDialog('Hubo un error al actualizar los registros: $e');
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    if (mounted && exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información obtenida exitosamente')),
      );

      setState(() {
        _keyPendientes = UniqueKey();
      });

      // if (_pendientesKey.currentState != null) {
      //   _pendientesKey.currentState!.recargarLecturas();
      // }
    }
  }

  Future<void> _enviarTodasLecturas() async {
    final hasInternet = await _verificarConexion();
    if (!hasInternet) {
      _showErrorDialog('Aún no hay conexión a internet');
      return;
    }

    _showLoadingDialog();

    final lecturasOffline = await cargarLecturasParaEnviarOffline();

    if (lecturasOffline.isEmpty) {
      _showErrorDialog('No hay lecturas para enviar.');
      return;
    }

    bool exito = true;

    try {
      for (var registroOffline in lecturasOffline) {
        final cliente = Cliente(
          periodo: registroOffline.cliente.periodo,
          idCliente: registroOffline.cliente.idCliente,
          condominio: registroOffline.cliente.condominio,
          departamento: registroOffline.cliente.departamento,
          rfc: registroOffline.cliente.rfc,
          clienteNombre: registroOffline.cliente.clienteNombre,
          lectura: registroOffline.cliente.lectura,
        );

        final bytes = await File(registroOffline.imagenMedidor).readAsBytes();

        final registro = RegistroLectura(
          cliente: cliente,
          imagenMedidor: bytes,
        );

        final enviado = await ApiService.enviarLectura(registro);

        if (enviado) {
          final lecturaActualizada = RegistroLecturaOffline(
            cliente: cliente,
            imagenMedidor: registroOffline.imagenMedidor,
            estatus: 2,
          );

          try {
            await editarLecturaOffline(lecturaActualizada);
          } catch (e) {
            exito = false;
            _showErrorDialog(
              'Hubo un error al actualizar el estatus de un registro: $e',
            );
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          _showErrorDialog(
            'No se pudo enviar la lectura del cliente ${cliente.clienteNombre}',
          );
          return;
        }
      }
    } catch (e) {
      exito = false;
      _showErrorDialog('Hubo un error al subir información a sinnube: $e');
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (mounted && exito) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('Éxito'),
          content: Text('Todas las lecturas fueron enviadas correctamente.'),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        _keyPendientes = UniqueKey();
        _keyEnviadas = UniqueKey();
        _keyTodas = UniqueKey();
      });

      // if (_pendientesKey.currentState != null &&
      //     _enviadasKey.currentState != null) {
      //   _pendientesKey.currentState!.recargarLecturas();
      //   _enviadasKey.currentState!.recargarLecturas();
      // }
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

  Future<bool> _verificarConexion() async {
    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro de lecturas'),
          backgroundColor: const Color(0xFF971c17),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pendientes'),
              Tab(text: 'Enviadas'),
              Tab(text: 'Todas'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              LecturasPendientesPage(key: _keyPendientes),
              LecturasEnviadasPage(key: _keyEnviadas),
              LecturasTodasPage(key: _keyTodas),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF971c17),
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: _obtenerInfFaltante,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Obtener información faltante',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            alignment: Alignment.center,
                            children: const [
                              Icon(Icons.cloud, size: 48, color: Colors.white),
                              Icon(
                                Icons.arrow_downward,
                                size: 32,
                                color: Color(0xFF971c17),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF971c17),
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: _enviarTodasLecturas,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Sincronizar información con sinnube',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            alignment: Alignment.center,
                            children: const [
                              Icon(Icons.cloud, size: 48, color: Colors.white),
                              Icon(
                                Icons.check,
                                size: 32,
                                color: Color(0xFF971c17),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
