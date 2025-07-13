import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lectura_gas_diamante/services/storage/data_storage.dart';
import 'package:lectura_gas_diamante/models/cliente.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lectura_gas_diamante/models/registro_lectura.dart';
import 'dart:convert';
import 'package:lectura_gas_diamante/services/storage/config_storage.dart';

class ApiService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'http://getpost.si-nube.appspot.com/';

  // URL base para la API v1
  static const String baseUrlV1 =
      'https://ep-dot-gas-sinube.appspot.com/api/v1/';

  static Future<Cliente?> fetchClienteDetalle(int? idCliente) async {
    final siNubeData = await getSiNubeData();

    if (idCliente == null) {
      throw Exception('ID de cliente no puede ser nulo.');
    }

    if (siNubeData == null) {
      throw Exception(
        'No hay configuración guardada (SiNubeData), acceda a la configuración de administrador.',
      );
    }

    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      throw Exception('Sin conexión a internet.');
    }

    final rawQuery =
        "SELECT c.cliente, c.rfcCliente, c.razonSocial, a.almacen as condominio, d.noInterior as departamento "
        "FROM DbCliente as c "
        "INNER JOIN DbCliente_A as a ON a.keyAncestor = c.key "
        "LEFT JOIN DbClienteDireccion as d ON d.empresa = c.empresa AND d.cliente = c.cliente AND d.moneda = c.moneda "
        "WHERE c.empresa = '${siNubeData.empresa}' and c.cliente = $idCliente and d.tipo = 1";

    final uri = Uri.parse(baseUrl).replace(
      path: '/getpost',
      queryParameters: {
        'tipo': '3',
        'emp': siNubeData.empresa,
        'suc': siNubeData.sucursal,
        'usu': siNubeData.usuario,
        'pas': siNubeData.password,
        'cns': rawQuery,
      },
    );

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final rawString = response.body.trim();
        if (rawString.isEmpty || !rawString.contains('¬')) return null;

        return Cliente.fromCustomFormat(rawString);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> enviarLectura(RegistroLectura registro) async {
    try {
      final siNubeData = await getSiNubeData();

      if (siNubeData == null) {
        throw Exception(
          'No hay configuración guardada (SiNubeData), acceda a la configuración de administrador.',
        );
      }

      final hasInternet =
          await InternetConnectionChecker.instance.hasConnection;
      if (!hasInternet) {
        throw Exception('Sin conexión a internet.');
      }

      final cliente = registro.cliente;

      if ([
        cliente.periodo,
        cliente.condominio,
        cliente.departamento,
        cliente.rfc,
        cliente.clienteNombre,
        cliente.lectura,
      ].any((e) => e == null || e.toString().isEmpty)) {
        throw Exception('Faltan datos obligatorios del cliente.');
      }

      final url = Uri.parse(
        '${baseUrlV1}lectura_agregar/${siNubeData.empresa}/${siNubeData.sucursal}/${siNubeData.usuario}/${siNubeData.password}',
      );

      final body = {
        "lstString": [
          cliente.periodo!,
          cliente.idCliente.toString(),
          cliente.condominio!,
          cliente.departamento!,
          cliente.rfc!,
          cliente.clienteNombre!,
          cliente.lectura!,
        ],
        "lstLong": registro.imagenMedidor,
      };

      final headers = {'Content-Type': 'application/json'};

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('No se pudo envíar el registro.');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>>
  obtenerDepartamentosPendientes() async {
    final siNubeData = await getSiNubeData();

    if (siNubeData == null) {
      throw Exception(
        'No hay configuración guardada (SiNubeData), acceda a la configuración de administrador.',
      );
    }

    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      throw Exception('Sin conexión a internet.');
    }

    final condominio = await getUltimoCondominio();

    if (condominio == null || condominio.isEmpty) {
      throw Exception('No hay condominio guardado. Por favor configure uno.');
    }

    final now = DateTime.now();
    final periodo = '${now.year}${now.month.toString().padLeft(2, '0')}';

    final url = Uri.parse(
      '${baseUrlV1}dameDepartamentosFaltantes/'
      '${siNubeData.empresa}/${siNubeData.sucursal}/${siNubeData.usuario}/'
      '${siNubeData.password}/$condominio/$periodo',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody is Map<String, dynamic> &&
            jsonBody.containsKey('departamentos')) {
          final List departamentos = jsonBody['departamentos'];

          return departamentos.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Error al obtener departamentos pendientes (${response.statusCode}).',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> obtenerCondominios() async {
    final siNubeData = await getSiNubeData();

    if (siNubeData == null) {
      throw Exception(
        'No hay configuración guardada (SiNubeData), acceda a la configuración de administrador.',
      );
    }

    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      throw Exception('Sin conexión a internet.');
    }

    final url = Uri.parse(
      '${baseUrlV1}dameCondominios/'
      '${siNubeData.empresa}/${siNubeData.sucursal}/${siNubeData.usuario}/'
      '${siNubeData.password}',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody is Map<String, dynamic> &&
            jsonBody.containsKey('condominios')) {
          final List condominios = jsonBody['condominios'];

          // Convertimos la lista dinámica a lista de String
          return List<String>.from(condominios);
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Error al obtener condominios (${response.statusCode}).',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
