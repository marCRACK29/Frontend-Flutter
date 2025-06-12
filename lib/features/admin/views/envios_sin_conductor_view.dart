import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'seleccionar_conductor_view.dart';

class EnviosSinConductorView extends StatefulWidget {
  @override
  _EnviosSinConductorViewState createState() => _EnviosSinConductorViewState();
}

class _EnviosSinConductorViewState extends State<EnviosSinConductorView> {
  late Future<List> envios;

  @override
  void initState() {
    super.initState();
    envios = ApiService().getEnviosSinConductor();
  }

  void _refresh() {
    setState(() {
      envios = ApiService().getEnviosSinConductor();
    });
  }

  void _irASeleccionarConductor(Map envio) async {
    final asignado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarConductorView(envio: envio),
      ),
    );
    if (asignado == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedidos sin conductor', style: TextStyle(color: Colors.white)), backgroundColor: Colors.indigo),
      body: FutureBuilder<List>(
        future: envios,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text("Sin pedidos pendientes"));
          return ListView(
  children: snapshot.data!
      .map((e) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue, width: 1),
            ),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text('Pedido #${e['id']}'),
              subtitle: Text(
                'Dirección: ${e['direccion_destino']}\nEstado: ${e['estado']['estado']}',
              ),
              onTap: () => _irASeleccionarConductor(e),
            ),
          ))
      .toList(),
);
        },
      ),
    );
  }
}
