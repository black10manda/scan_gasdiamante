import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorage = FlutterSecureStorage();
const _keyUltimoCondominio = 'ultimo_condominio';

Future<bool> saveUltimoCondominio(String condominio) async {
  final existing = await getUltimoCondominio();
  if (existing != null) return false;

  await secureStorage.write(key: _keyUltimoCondominio, value: condominio);
  return true;
}

Future<String?> getUltimoCondominio() async {
  return await secureStorage.read(key: _keyUltimoCondominio);
}

Future<void> upsertUltimoCondominio(String condominio) async {
  await secureStorage.write(key: _keyUltimoCondominio, value: condominio);
}

Future<void> deleteUltimoCondominio() async {
  await secureStorage.delete(key: _keyUltimoCondominio);
}
