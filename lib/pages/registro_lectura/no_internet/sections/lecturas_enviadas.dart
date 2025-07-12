import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/services/storage/lectura_offline_storage.dart';
import 'package:lectura_gas_diamante/models/registro_lectura_offline.dart';
import 'package:lectura_gas_diamante/widgets/lectura_card.dart';

class LecturasEnviadasPage extends StatefulWidget {
  const LecturasEnviadasPage({super.key});

  @override
  State<LecturasEnviadasPage> createState() => LecturasEnviadasPageState();
}

class LecturasEnviadasPageState extends State<LecturasEnviadasPage> {
  List<RegistroLecturaOffline> _lecturas = [];

  @override
  void initState() {
    super.initState();
    _cargarLecturas();
  }

  Future<void> _cargarLecturas() async {
    final lecturas = await cargarLecturasEnviadasOffline();
    if (!mounted) return;
    setState(() {
      _lecturas = lecturas;
    });
  }

  void recargarLecturas() {
    _cargarLecturas();
  }

  @override
  Widget build(BuildContext context) {
    if (_lecturas.isEmpty) {
      return const Center(child: Text('No hay registros'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _lecturas.length,
      itemBuilder: (context, index) {
        return LecturaCard(lectura: _lecturas[index]);
      },
    );
  }
}
