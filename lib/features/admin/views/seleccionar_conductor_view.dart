import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SeleccionarConductorView extends StatefulWidget {
  final Map envio;
  SeleccionarConductorView({required this.envio});

  @override
  _SeleccionarConductorViewState createState() => _SeleccionarConductorViewState();
}

class _SeleccionarConductorViewState extends State<SeleccionarConductorView> {
  late Future<List> conductores;

  @override
  void initState() {
    super.initState();
    conductores = ApiService().getConductores();
  }

  void _confirmarAsignacion(Map conductor) async {
    final ok = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar asignación"),
        content: Text(
            "¿Quieres asignar el pedido #${widget.envio['id']} al conductor ${conductor['nombre']}?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("Asignar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (ok == true) {
      final result = await ApiService().asignarConductor(widget.envio['id'], conductor['RUT']);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("¡Asignación exitosa!")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al asignar")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar conductor', style: TextStyle(color: Colors.white)), backgroundColor: Colors.indigo),
      body: FutureBuilder<List>(
        future: conductores,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text("Sin conductores"));
          return ListView(
  children: snapshot.data!
      .map((c) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue, width: 1),
            ),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text('${c['nombre']}'),
              subtitle: Text('RUT: ${c['RUT']}'),
              onTap: () => _confirmarAsignacion(c),
            ),
          ))
      .toList(),
);

        },
      ),
    );
  }
}
