import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../services/tracking_service.dart';
import '../../maps/services/api/nominatim_osrm_service.dart';
import '../widgets/status_timeline.dart';

class TrackingScreen extends StatefulWidget {
  final int envioId;
  final String userType; // 'cliente' o 'conductor'
  final String userId;

  const TrackingScreen({
    super.key,
    required this.envioId,
    required this.userType,
    required this.userId,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  final NominatimOsrmService _locationService = NominatimOsrmService();

  // Cache para coordenadas de direcciones
  final Map<String, LatLng> _addressCache = {};
  bool _isLoadingRoute = false;
  LatLng _currentCenter = const LatLng(
    -36.8485,
    -73.0524,
  ); // Concepción por defecto

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackingService = Provider.of<TrackingService>(
        context,
        listen: false,
      );
      trackingService.initialize().then((_) {
        trackingService.joinTracking(
          widget.envioId,
          widget.userType,
          widget.userId,
        );

        // Si es conductor, iniciar tracking de ubicación
        if (widget.userType == 'conductor') {
          trackingService.startLocationTracking(widget.userId);
        }
      });
    });
  }

  @override
  void dispose() {
    final trackingService = Provider.of<TrackingService>(
      context,
      listen: false,
    );
    trackingService.leaveTracking();
    if (widget.userType == 'conductor') {
      trackingService.stopLocationTracking();
    }
    super.dispose();
  }

  /// Convierte dirección a coordenadas usando cache
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    if (_addressCache.containsKey(address)) {
      return _addressCache[address];
    }

    try {
      final coordinates = await _locationService.buscarUbicacion(address);
      if (coordinates != null) {
        _addressCache[address] = coordinates;
        return coordinates;
      }
    } catch (e) {
      print('Error geocodificando dirección $address: $e');
    }

    return null;
  }

  /// Calcula y dibuja la ruta entre dos puntos
  Future<void> _calculateRoute(LatLng origin, LatLng destination) async {
    if (_isLoadingRoute) return;

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final routePoints = await _locationService.fetchRoute(
        origin,
        destination,
      );

      if (routePoints.isNotEmpty) {
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              points: routePoints,
              color: Colors.blue,
              strokeWidth: 4.0,
              isDotted: false,
            ),
          );
        });

        // Ajustar vista para mostrar toda la ruta
        _fitRouteInView(routePoints);
      }
    } catch (e) {
      print('Error calculando ruta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo calcular la ruta'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  /// Ajusta la vista del mapa para mostrar todos los puntos de la ruta
  void _fitRouteInView(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
    );
  }

  Future<void> _updateMarkers(TrackingService trackingService) async {
    _markers.clear();

    final status = trackingService.currentEnvioStatus;

    if (status == null) return; // los marcadores se crean solo si status no es null

    print('Origen: ${status['direccion_origen']}');
    print('Destino: ${status['direccion_destino']}');
    print('Latitud: ${status['latitude']}, Longitud: ${status['longitude']}');

    LatLng? conductorPosition;
    LatLng? origenPosition;
    LatLng? destinoPosition;

    // Marcador del conductor (posición actual)
    if (status['latitude'] != null && status['longitude'] != null) {
      conductorPosition = LatLng(
        double.parse(status['latitude'].toString()),
        double.parse(status['longitude'].toString()),
      );

      _markers.add(
        Marker(
          point: conductorPosition,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

      // Actualizar centro del mapa si es la primera vez
      _currentCenter = conductorPosition;
    }

    // Marcador de origen
    if (status['direccion_origen'] != null) {
      origenPosition = await _getCoordinatesFromAddress(
        status['direccion_origen'],
      );

      if (origenPosition != null) {
        _markers.add(
          Marker(
            point: origenPosition,
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.radio_button_checked,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      }
    }

    // Marcador de destino
    if (status['direccion_destino'] != null) {
      destinoPosition = await _getCoordinatesFromAddress(
        status['direccion_destino'],
      );

      if (destinoPosition != null) {
        _markers.add(
          Marker(
            point: destinoPosition,
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      }
    }

    // Calcular ruta según el estado del envío
    await _calculateRouteBasedOnStatus(
      status['estado'] ?? status['status'],
      conductorPosition,
      origenPosition,
      destinoPosition,
    );

    if (mounted) {
      setState(() {});
    }
  }

  /// Calcula la ruta apropiada según el estado del envío
  Future<void> _calculateRouteBasedOnStatus(
    String? estado,
    LatLng? conductorPos,
    LatLng? origenPos,
    LatLng? destinoPos,
  ) async {
    switch (estado) {
      case 'asignado':
      case 'en_camino_recogida':
        // Ruta del conductor al origen
        if (conductorPos != null && origenPos != null) {
          await _calculateRoute(conductorPos, origenPos);
        }
        break;

      case 'recogido':
      case 'en_transito':
        // Ruta del conductor al destino
        if (conductorPos != null && destinoPos != null) {
          await _calculateRoute(conductorPos, destinoPos);
        }
        break;

      case 'entregado':
        // Mostrar ruta completa origen -> destino
        if (origenPos != null && destinoPos != null) {
          await _calculateRoute(origenPos, destinoPos);
        }
        break;

      default:
        // Para otros estados, limpiar rutas
        if (mounted) {
          setState(() {
            _polylines.clear();
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento de Envío')),
      body: Consumer<TrackingService>(
        builder: (context, trackingService, child) {
          final status = trackingService.currentEnvioStatus;

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentCenter,
                        initialZoom: 13.0,
                        onMapReady: () {
                          _updateMarkers(trackingService);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                          tileProvider: CancellableNetworkTileProvider(),
                        ),
                        MarkerLayer(markers: _markers),
                        PolylineLayer(polylines: _polylines),
                      ],
                    ),
                    if (_isLoadingRoute)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
              if (status != null)
                EnvioStatusTimeline(
                  // Asegurar que el estado se pase correctamente
                  currentStatus: status['estado']?.toString().toLowerCase() ?? 
                                status['status']?.toString().toLowerCase() ?? 
                                'pendiente',
                  statusHistory: status['historial_estados'],
                ),
              ],
          );
        },
      ),
    );
  }

  String _mapStyle = 'standard';

  String _getCurrentTileTemplate() {
    switch (_mapStyle) {
      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'terrain':
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  void _changeMapStyle(String style) {
    setState(() {
      _mapStyle = style;
    });
  }

  /// Centra el mapa en la ubicación actual del conductor
  void _centerMapOnCurrentLocation() {
    final conductorMarker =
        _markers
            .where((m) => m.child.toString().contains('local_shipping'))
            .firstOrNull;

    if (conductorMarker != null) {
      _mapController.move(conductorMarker.point, 15.0);
    } else {
      _mapController.move(_currentCenter, 13.0);
    }
  }

  /// Refresca el tracking manualmente
  void _refreshTracking() {
    final trackingService = Provider.of<TrackingService>(
      context,
      listen: false,
    );
    trackingService.leaveTracking();
    trackingService.joinTracking(
      widget.envioId,
      widget.userType,
      widget.userId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Actualizando tracking...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEnvioInfo(Map<String, dynamic>? status) {
    if (status == null) {
      return const Text('Cargando información del envío...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getStatusIcon(status['estado'] ?? status['status']),
              color: _getStatusColor(status['estado'] ?? status['status']),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getStatusText(status['estado'] ?? status['status']),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_isLoadingRoute)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Información de direcciones con iconos mejorados
        if (status['direccion_origen'] != null) ...[
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.radio_button_checked,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Origen: ${status['direccion_origen']}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        if (status['direccion_destino'] != null) ...[
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Destino: ${status['direccion_destino']}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Información de personas en cards compactas
        Row(
          children: [
            Expanded(
              child: _buildPersonCard(
                'Conductor',
                status['conductor_nombre'],
                status['conductor_telefono'],
                Icons.local_shipping,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPersonCard(
                'Cliente',
                status['cliente_nombre'],
                status['cliente_telefono'],
                Icons.person,
                Colors.green,
              ),
            ),
          ],
        ),

        if (status['last_location_update'] != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Actualizado: ${_formatDateTime(status['last_location_update'])}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPersonCard(
    String title,
    String? name,
    String? phone,
    IconData icon,
    Color color,
  ) {
    if (name == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              '$title: N/A',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          if (phone != null)
            Text(
              phone,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pendiente':
        return Icons.pending;
      case 'en_transito':
        return Icons.local_shipping;
      case 'entregado':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'en_transito':
        return Colors.indigo;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_transito':
        return 'En tránsito';
      case 'entregado':
        return 'Entregado';
      default:
        return 'Estado desconocido';
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
