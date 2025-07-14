import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/sinube_data.dart';

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
