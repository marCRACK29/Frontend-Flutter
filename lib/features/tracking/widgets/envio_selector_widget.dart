import 'package:flutter/material.dart';
import '../models/envio_model.dart';

class EnvioSelectorWidget extends StatelessWidget {
  final List<Envio> envios;
  final Envio? selectedEnvio;
  final Function(Envio) onEnvioSelected;
  final bool isLoading;

  const EnvioSelectorWidget({
    Key? key,
    required this.envios,
    required this.selectedEnvio,
    required this.onEnvioSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Seleccionar Envío',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (envios.isEmpty)
            const Text('No hay envíos disponibles')
          else
            DropdownButton<Envio>(
              value: selectedEnvio,
              isExpanded: true,
              hint: const Text('Selecciona un envío'),
              items:
                  envios.map((Envio envio) {
                    return DropdownMenuItem<Envio>(
                      value: envio,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Envío #${envio.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              envio.direccionDestino,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (Envio? newValue) {
                if (newValue != null) {
                  onEnvioSelected(newValue);
                }
              },
            ),
        ],
      ),
    );
  }
}
