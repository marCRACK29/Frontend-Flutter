import 'package:flutter/material.dart';
import '../models/envio_model.dart';
import '../services/delivery_service.dart';
import '../../tracking/views/tracking_screen.dart';

class DeliveryDetailView extends StatefulWidget {
  final int envioId; // Cambiado: ahora usa int en lugar de EnvioModel
  
  const DeliveryDetailView({super.key, required this.envioId});

  @override
  State<DeliveryDetailView> createState() => _DeliveryDetailViewState();
}

class _DeliveryDetailViewState extends State<DeliveryDetailView> {
  final DeliveryService _deliveryService = DeliveryService();

  EnvioModel? _envio; 
  String? _estadoActual;
  String? _direccionActual;
  bool _cargando = false;
  bool _cargandoInicial = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatosEnvio();
  }

  // Método para cargar los datos del envío desde el backend
  Future<void> _cargarDatosEnvio() async {
    setState(() {
      _cargandoInicial = true;
      _errorMessage = null;
    });

    try {
      // Obtener datos actuales del backend
      final envioActualizado = await _deliveryService.obtenerEnvioPorId(widget.envioId);
      
      setState(() {
        _envio = envioActualizado;
        _estadoActual = envioActualizado.estado;
        _direccionActual = envioActualizado.direccionDestino;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cargandoInicial = false);
    }
  }

  // Método para refrescar solo el estado desde el backend
  Future<void> _actualizarEstado() async {
    try {
      // Opción 1: Obtener todo el envío actualizado
      final envioActualizado = await _deliveryService.obtenerEnvioPorId(widget.envioId);
      
      setState(() {
        _envio = envioActualizado;
        _estadoActual = envioActualizado.estado;
        _direccionActual = envioActualizado.direccionDestino;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _confirmarEntrega() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: const Text(
          '¿Estás seguro de marcar este envío como "Entregado"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() => _cargando = true);

    try {
      await _deliveryService.actualizarEstadoEnvio(
        widget.envioId,
        'Entregado',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrega confirmada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Actualizar el estado desde el backend para asegurar consistencia
      await _actualizarEstado();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar entrega: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _abrirMapa() {
    if (_envio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pueden cargar los datos del envío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(
          envioId: widget.envioId, // Convertir a String si es necesario
          userType: 'conductor',
          userId: '15.123.102-4', // ID del conductor actual
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga los datos iniciales
    if (_cargandoInicial) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Envío')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos del envío...'),
            ],
          ),
        ),
      );
    }

    // Mostrar error si no se pudieron cargar los datos
    if (_envio == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Envío')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Error al cargar los datos del envío',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  onPressed: _cargarDatosEnvio,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Envío #${widget.envioId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _actualizarEstado,
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del envío
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Envío',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Dirección:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _direccionActual ?? 'Dirección no disponible',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Estado actual:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(_estadoActual),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _estadoActual ?? "No disponible",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Botones de acción
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _cargando 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: const Text('Confirmar Entrega'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: (_cargando || _estadoActual == 'Entregado') 
                          ? null 
                          : _confirmarEntrega,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text('Abrir Mapa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _abrirMapa,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para obtener el color según el estado
  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en_transito':
      case 'en tránsito':
        return Colors.blue;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}