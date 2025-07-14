import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lectura_gas_diamante/models/registro_lectura_offline.dart';
import 'dart:convert';
import 'dart:io';

final storage = FlutterSecureStorage();
const _keyLecturasOffline = 'lecturas_offline';

Future<void> guardarLecturasOffline(
  List<RegistroLecturaOffline> registros,
) async {
  final List<Map<String, dynamic>> jsonList = registros
      .map((r) => r.toJson())
      .toList();
  final String jsonString = jsonEncode(jsonList);
  await storage.write(key: _keyLecturasOffline, value: jsonString);
}

Future<List<RegistroLecturaOffline>> cargarLecturasOffline() async {
  final String? jsonString = await storage.read(key: _keyLecturasOffline);

  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList
      .map(
        (item) => RegistroLecturaOffline.fromJson(item as Map<String, dynamic>),
      )
      .toList();
}

Future<List<RegistroLecturaOffline>> cargarLecturasPendientesOffline() async {
  final String? jsonString = await storage.read(key: _keyLecturasOffline);

  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList
      .map(
        (item) => RegistroLecturaOffline.fromJson(item as Map<String, dynamic>),
      )
      .where((registro) => registro.estatus == 0 || registro.estatus == 1)
      .toList();
}

Future<List<RegistroLecturaOffline>> cargarLecturasParaEnviarOffline() async {
  final String? jsonString = await storage.read(key: _keyLecturasOffline);

  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList
      .map(
        (item) => RegistroLecturaOffline.fromJson(item as Map<String, dynamic>),
      )
      .where((registro) => registro.estatus == 1)
      .toList();
}

Future<List<RegistroLecturaOffline>> cargarLecturasEnviadasOffline() async {
  final String? jsonString = await storage.read(key: _keyLecturasOffline);

  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList
      .map(
        (item) => RegistroLecturaOffline.fromJson(item as Map<String, dynamic>),
      )
      .where((registro) => registro.estatus == 2)
      .toList();
}

Future<void> agregarLecturaOffline(RegistroLecturaOffline nueva) async {
  final registros = await cargarLecturasOffline();
  registros.add(nueva);
  await guardarLecturasOffline(registros);
}

// Future<void> borrarLecturasOffline() async {
//   await storage.delete(key: _keyLecturasOffline);
// }

Future<void> editarLecturaOffline(RegistroLecturaOffline editado) async {
  final registros = await cargarLecturasOffline();

  final index = registros.indexWhere(
    (r) => r.cliente.idCliente == editado.cliente.idCliente,
  );

  if (index != -1) {
    registros[index] = editado;
    await guardarLecturasOffline(registros);
  } else {
    throw Exception('Registro no encontrado para editar');
  }
}

Future<void> eliminarLecturaOffline(int idCliente) async {
  final registros = await cargarLecturasOffline();

  // Buscar el registro por idCliente
  final registroAEliminar = registros.firstWhere(
    (r) => r.cliente.idCliente == idCliente,
    orElse: () =>
        throw Exception('Registro con idCliente $idCliente no encontrado.'),
  );

  final path = registroAEliminar.imagenMedidor;
  final archivo = File(path);

  if (await archivo.exists()) {
    try {
      await archivo.delete();
    } catch (e) {
      rethrow;
    }
  }

  registros.removeWhere((r) => r.cliente.idCliente == idCliente);

  await guardarLecturasOffline(registros);
}
