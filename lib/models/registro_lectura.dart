import 'cliente.dart';
import 'dart:typed_data';
import 'dart:convert';

class RegistroLectura {
  final Cliente cliente;
  final Uint8List imagenMedidor;

  RegistroLectura({required this.cliente, required this.imagenMedidor});

  Map<String, dynamic> toJson() {
    return {...cliente.toJson(), 'imagenMedidor': base64Encode(imagenMedidor)};
  }

  factory RegistroLectura.fromJson(Map<String, dynamic> json) {
    return RegistroLectura(
      cliente: Cliente.fromJson(json),
      imagenMedidor: base64Decode(json['imagenMedidor']),
    );
  }
}
