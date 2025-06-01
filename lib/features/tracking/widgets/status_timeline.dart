// lib/features/tracking/widgets/envio_status_timeline.dart
import 'package:flutter/material.dart';

class EnvioStatusTimeline extends StatelessWidget {
  final String currentStatus;
  final List<Map<String, dynamic>>? statusHistory;

  const EnvioStatusTimeline({
    Key? key,
    required this.currentStatus,
    this.statusHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'key': 'pendiente', 'title': 'Pendiente', 'description': 'Envío creado'},
      {'key': 'asignado', 'title': 'Asignado', 'description': 'Conductor asignado'},
      {'key': 'en_camino_recogida', 'title': 'En camino', 'description': 'Yendo a recoger'},
      {'key': 'recogido', 'title': 'Recogido', 'description': 'Paquete recogido'},
      {'key': 'en_transito', 'title': 'En tránsito', 'description': 'Camino al destino'},
      {'key': 'entregado', 'title': 'Entregado', 'description': 'Paquete entregado'},
    ];

    int currentIndex = statuses.indexWhere((s) => s['key'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del Envío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...statuses.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> status = entry.value;
            
            bool isCompleted = index <= currentIndex;
            bool isCurrent = index == currentIndex;
            bool isLast = index == statuses.length - 1;
            
            return _buildTimelineItem(
              title: status['title'],
              description: status['description'],
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              timestamp: _getTimestampForStatus(status['key']),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    String? timestamp,
  }) {
    Color circleColor = isCompleted ? Colors.green : Colors.grey[300]!;
    Color lineColor = isCompleted ? Colors.green : Colors.grey[300]!;
    
    if (isCurrent && isCompleted) {
      circleColor = Colors.blue;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline visual
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                border: Border.all(
                  color: isCurrent ? Colors.blue : circleColor,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      isCurrent ? Icons.radio_button_checked : Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: lineColor,
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.grey[700] : Colors.grey[500],
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _getTimestampForStatus(String statusKey) {
    if (statusHistory == null) return null;
    
    final history = statusHistory!.firstWhere(
      (h) => h['status'] == statusKey,
      orElse: () => {},
    );
    
    if (history.isNotEmpty && history['timestamp'] != null) {
      try {
        final date = DateTime.parse(history['timestamp']);
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
}