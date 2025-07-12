// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/models/registro_lectura_offline.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LecturaCard extends StatelessWidget {
  final RegistroLecturaOffline lectura;

  const LecturaCard({super.key, required this.lectura});

  @override
  Widget build(BuildContext context) {
    // final imagenPath = lectura.imagenMedidor;
    // final existeImagen = File(imagenPath).existsSync();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color.fromARGB(255, 241, 241, 241),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildRow(
                    "ID Cliente:",
                    lectura.cliente.idCliente.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(lectura.estatus),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Center(child: _getStatusIcon(lectura.estatus)),
                  ),
                ),
              ],
            ),
            _buildRow("Condiminio:", lectura.cliente.condominio),
            _buildRow("Departamento:", lectura.cliente.departamento),
            _buildRow("Cliente:", lectura.cliente.clienteNombre),
            _buildRow("RFC:", lectura.cliente.rfc),
            _buildRow("Período:", lectura.cliente.periodo?.toString()),
            _buildRow("Código medidor:", lectura.cliente.lectura),

            const SizedBox(height: 8),

            // Imagen
            // if (imagenPath.isNotEmpty && existeImagen)
            //   Center(
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(6),
            //       child: Image.file(
            //         File(imagenPath),
            //         width: 100,
            //         height: 100,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   )
            // else
            //   const Center(
            //     child: Icon(
            //       Icons.image_not_supported,
            //       color: Colors.grey,
            //       size: 50,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade600),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: Text(
                value ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(int estatus) {
    switch (estatus) {
      case 0:
        return const FaIcon(
          FontAwesomeIcons.question,
          color: Colors.white,
          size: 20,
        );
      case 1:
        return const FaIcon(
          FontAwesomeIcons.exclamation,
          color: Colors.white,
          size: 20,
        );
      case 2:
        return const Icon(Icons.check, color: Colors.white, size: 20);
      default:
        return const FaIcon(
          FontAwesomeIcons.circleQuestion,
          color: Colors.white,
          size: 20,
        );
    }
  }

  Color _getStatusColor(int estatus) {
    switch (estatus) {
      case 0:
        return const Color.fromARGB(255, 80, 159, 212);
      case 1:
        return const Color.fromARGB(255, 255, 198, 10);
      case 2:
        return Colors.green;
      default:
        return const Color.fromARGB(255, 0, 0, 0);
    }
  }
}
