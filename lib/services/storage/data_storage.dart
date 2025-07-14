import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/sinube_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final storage = FlutterSecureStorage();
const _keySiNubeData = 'sinube_data';

Future<void> saveSiNubeData(SiNubeData data) async {
  try {
    final jsonString = jsonEncode(data.toJson());
    await storage.write(key: _keySiNubeData, value: jsonString);
  } catch (e) {
    rethrow;
  }
}

Future<SiNubeData?> getSiNubeData() async {
  final jsonString = await storage.read(key: _keySiNubeData);
  if (jsonString == null) return null;
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return SiNubeData.fromJson(jsonMap);
}

Future<bool> addSiNubeDataIfNotExists(SiNubeData newData) async {
  final existingData = await getSiNubeData();
  if (existingData != null) {
    return false;
  } else {
    await saveSiNubeData(newData);
    return true;
  }
}

Future<bool> editSiNubeData(SiNubeData updatedData) async {
  final existingData = await getSiNubeData();
  if (existingData == null) {
    return false;
  } else {
    await saveSiNubeData(updatedData);
    return true;
  }
}

Future<void> upsertSiNubeData(SiNubeData data) async {
  await saveSiNubeData(data);
}

Future<void> initSinubeData() async {
  final data = await getSiNubeData();
  if (data == null) {
    final pass = dotenv.env['SINUBE_PASS']!.toString();
    final empresa = dotenv.env['SINUBE_EMPRESA']!;
    final sucursal = dotenv.env['SINUBE_SUCURSAL']!;
    final usuario = dotenv.env['SINUBE_USUARIO']!;
    final password = pass;
    final calidad = 50;
    final tamano = 50;
    final dataGasDiamante = SiNubeData(
      empresa: empresa,
      sucursal: sucursal,
      usuario: usuario,
      password: password,
      calidad: calidad,
      tamano: tamano,
    );
    await saveSiNubeData(dataGasDiamante);
  }
}
