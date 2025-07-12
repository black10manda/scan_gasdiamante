import 'cliente.dart';

class RegistroLecturaOffline {
  final Cliente cliente;
  final String imagenMedidor;
  final int estatus; // Nuevo campo

  RegistroLecturaOffline({
    required this.cliente,
    required this.imagenMedidor,
    required this.estatus,
  });

  Map<String, dynamic> toJson() {
    return {
      ...cliente.toJson(),
      'imagenMedidor': imagenMedidor,
      'estatus': estatus, // Agregado a la conversión
    };
  }

  factory RegistroLecturaOffline.fromJson(Map<String, dynamic> json) {
    return RegistroLecturaOffline(
      cliente: Cliente.fromJson(json),
      imagenMedidor: json['imagenMedidor'],
      estatus: json['estatus'] ?? 0, // Default en caso de que falte
    );
  }
}
