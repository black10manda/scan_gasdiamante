class SiNubeData {
  final String empresa;
  final String sucursal;
  final String usuario;
  final String password;
  final int calidad;
  final int tamano;

  SiNubeData({
    required this.empresa,
    required this.sucursal,
    required this.usuario,
    required this.password,
    required this.calidad,
    required this.tamano,
  });

  Map<String, dynamic> toJson() {
    return {
      'empresa': empresa,
      'sucursal': sucursal,
      'usuario': usuario,
      'password': password,
      'calidad': calidad,
      'tamano': tamano,
    };
  }

  factory SiNubeData.fromJson(Map<String, dynamic> json) => SiNubeData(
    empresa: json['empresa'],
    sucursal: json['sucursal'],
    usuario: json['usuario'],
    password: json['password'],
    calidad: json['calidad'],
    tamano: json['tamano'],
  );
}
