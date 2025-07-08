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
}
