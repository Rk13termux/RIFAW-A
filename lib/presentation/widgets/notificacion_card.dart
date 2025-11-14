import 'package:flutter/material.dart';
import '../../data/models/notificacion.dart';
import '../../core/utils/helpers.dart';

class NotificacionCard extends StatelessWidget {
  final NotificacionModel notificacion;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificacionCard({
    super.key,
    required this.notificacion,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notificacion.leida ? Colors.white : Colors.blue.shade50,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTipoColor(notificacion.tipo).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTipoIcon(notificacion.tipo),
                  color: _getTipoColor(notificacion.tipo),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: notificacion.leida
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                          ),
                        ),
                        if (!notificacion.leida)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notificacion.mensaje,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateHelper.formatChatTime(notificacion.fecha),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Botón eliminar
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.grey,
                  onPressed: onDelete,
                  iconSize: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTipoIcon(String? tipo) {
    switch (tipo) {
      case 'rifa':
        return Icons.celebration;
      case 'boleto':
        return Icons.confirmation_number;
      case 'chat':
        return Icons.chat_bubble;
      case 'sorteo':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color _getTipoColor(String? tipo) {
    switch (tipo) {
      case 'rifa':
        return Colors.purple;
      case 'boleto':
        return Colors.green;
      case 'chat':
        return Colors.blue;
      case 'sorteo':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
