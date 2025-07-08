class Cliente {
  final int idCliente;
  final String condominio;
  final String departamento;
  final String clienteNombre;
  final String rfc;
  final int periodo;

  Cliente({
    required this.idCliente,
    required this.condominio,
    required this.departamento,
    required this.clienteNombre,
    required this.rfc,
    required this.periodo,
  });

  Map<String, dynamic> toJson() {
    return {
      'idCliente': idCliente,
      'condominio': condominio,
      'departamento': departamento,
      'clienteNombre': clienteNombre,
      'rfc': rfc,
      'periodo': periodo,
    };
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    idCliente: json['idCliente'],
    condominio: json['condominio'],
    departamento: json['departamento'],
    clienteNombre: json['clienteNombre'],
    rfc: json['rfc'],
    periodo: json['periodo'],
  );

  factory Cliente.fromCustomFormat(String rawData) {
    final parts = rawData.split('¬');
    if (parts.length != 2) {
      throw FormatException('Formato inválido de respuesta.');
    }

    final values = parts[1].split('|');

    if (values.length < 5) {
      throw FormatException('Datos incompletos del cliente.');
    }

    final now = DateTime.now();
    final periodo = now.year * 100 + now.month;

    return Cliente(
      idCliente: int.tryParse(values[0]) ?? 0,
      rfc: values[1],
      clienteNombre: values[2],
      condominio: values[3],
      departamento: values[4],
      periodo: periodo,
    );
  }
}
