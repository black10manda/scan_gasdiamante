class Cliente {
  final int? periodo;
  final int idCliente;
  final String? condominio;
  final String? departamento;
  final String? rfc;
  final String? clienteNombre;
  final String? lectura;

  Cliente({
    this.periodo,
    required this.idCliente,
    this.condominio,
    this.departamento,
    this.rfc,
    this.clienteNombre,
    this.lectura,
  });

  Map<String, dynamic> toJson() {
    return {
      if (periodo != null) 'periodo': periodo,
      'idCliente': idCliente,
      if (condominio != null) 'condominio': condominio,
      if (departamento != null) 'departamento': departamento,
      if (rfc != null) 'rfc': rfc,
      if (clienteNombre != null) 'clienteNombre': clienteNombre,
      if (lectura != null) 'lectura': lectura,
    };
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    periodo: json['periodo'],
    idCliente: json['idCliente'],
    condominio: json['condominio'],
    departamento: json['departamento'],
    rfc: json['rfc'],
    clienteNombre: json['clienteNombre'],
    lectura: json['lectura'],
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
      periodo: periodo,
      idCliente: int.tryParse(values[0]) ?? 0,
      condominio: values[3],
      departamento: values[4],
      rfc: values[1],
      clienteNombre: values[2],
      lectura: null,
    );
  }
}
