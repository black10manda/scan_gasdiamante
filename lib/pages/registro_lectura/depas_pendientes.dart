import 'package:flutter/material.dart';
import 'package:lectura_gas_diamante/services/storage/config_storage.dart';
import 'package:lectura_gas_diamante/services/api/api_service.dart';

class DepasPendientesPage extends StatefulWidget {
  const DepasPendientesPage({super.key});

  @override
  State<DepasPendientesPage> createState() => _DepasPendientesPageState();
}

class _DepasPendientesPageState extends State<DepasPendientesPage> {
  late Future<List<dynamic>> _futureItems;
  bool _showDepartamentos = true;
  String _condominioActual = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final condominio = await getUltimoCondominio();
    if (condominio == null || condominio.isEmpty) {
      setState(() {
        _showDepartamentos = false;
        _condominioActual = '';
        _futureItems = ApiService.obtenerCondominios();
      });
    } else {
      setState(() {
        _showDepartamentos = true;
        _condominioActual = condominio;
        _futureItems = ApiService.obtenerDepartamentosPendientes();
      });
    }
  }

  void _elegirOtroCondominio() async {
    await deleteUltimoCondominio();
    setState(() {
      _showDepartamentos = false;
      _condominioActual = '';
      _futureItems = ApiService.obtenerCondominios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _showDepartamentos ? 'Departamentos Pendientes' : 'Condominios',
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
        actions: _showDepartamentos
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.settings),
                  onSelected: (value) {
                    if (value == 'elegir') {
                      _elegirOtroCondominio();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'elegir',
                      child: Text('Elegir condominio'),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _futureItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  _showDepartamentos
                      ? 'No hay departamentos pendientes.'
                      : 'No hay condominios disponibles.',
                ),
              );
            }

            final items = snapshot.data!;

            return Column(
              children: [
                if (_showDepartamentos)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Center(
                      child: Text(
                        'Departamentos pendientes de: $_condominioActual',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      if (_showDepartamentos) {
                        final cliente =
                            (item as Map<String, dynamic>)['cliente']
                                ?.toString() ??
                            'Desconocido';
                        final depto =
                            item['departamento']?.toString() ?? 'Desconocido';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.apartment,
                              color: Color(0xFF971c17),
                            ),
                            title: Text('Departamento: $depto'),
                            subtitle: Text('Cliente: $cliente'),
                          ),
                        );
                      } else {
                        final condominio = item.toString();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.home_work,
                              color: Color(0xFF971c17),
                            ),
                            title: Text('Condominio: $condominio'),
                            onTap: () async {
                              await upsertUltimoCondominio(condominio);
                              setState(() {
                                _showDepartamentos = true;
                                _condominioActual = condominio;
                                _futureItems =
                                    ApiService.obtenerDepartamentosPendientes();
                              });
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
