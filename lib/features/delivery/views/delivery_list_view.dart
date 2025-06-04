import 'package:flutter/material.dart';
import '../models/envio_model.dart';
import '../services/delivery_service.dart';
import 'delivery_detail_view.dart';

class DeliveryListView extends StatefulWidget {
  @override
  _DeliveryListViewState createState() => _DeliveryListViewState();
}

class _DeliveryListViewState extends State<DeliveryListView> {
  late Future<List<EnvioModel>> _deliveries;

  @override
  void initState() {
    super.initState();
    // Cambia el conductorId por el que corresponda en tu sistema real
    _deliveries = DeliveryService().obtenerEnviosPorConductor("15.123.102-4");
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
                title: Text('Envíos Asignados'),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white, // Para que el texto salga blanco
              ),
        body: FutureBuilder<List<EnvioModel>>(
          future: _deliveries,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay envíos asignados'));
            }

            final deliveries = snapshot.data!;
            return ListView.builder(
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final envio = deliveries[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Envío #${envio.idEnvio}'),
                    subtitle: Text('Estado: ${envio.estadoActual.estado}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeliveryDetailView(envio: envio),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
}
