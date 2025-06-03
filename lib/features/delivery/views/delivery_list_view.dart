import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/delivery_provider.dart';
import 'delivery_detail_view.dart';

class DeliveryListView extends StatefulWidget {
  const DeliveryListView({super.key});

  @override
  State<DeliveryListView> createState() => _DeliveryListViewState();
}

class _DeliveryListViewState extends State<DeliveryListView> {
  @override
  void initState() {
    super.initState();

    // Esperar a que el widget se construya antes de llamar al provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DeliveryProvider>(context, listen: false);
      provider.cargarEnvios('15.123.102-4'); // Puedes cambiar '1' por el ID real del conductor
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envíos Asignados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DeliveryProvider>(context, listen: false).cargarEnvios('15.123.123-5');
            },
          )
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          if (provider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.envios.isEmpty) {
            return const Center(child: Text('No hay envíos asignados.'));
          }

          return ListView.builder(
            itemCount: provider.envios.length,
            itemBuilder: (context, index) {
              final envio = provider.envios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(envio.direccion),
                  subtitle: Text('Estado: ${envio.estado}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeliveryDetailView(envio: envio),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
