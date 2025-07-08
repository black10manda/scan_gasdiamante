import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lectura_gas_diamante/services/data_storage.dart';
import 'package:lectura_gas_diamante/models/cliente.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ApiService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'http://getpost.si-nube.appspot.com/';

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
}
