import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../widgets/notificacion_card.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificaciones = ref.watch(notificacionesProvider);
    final noLeidas = ref.watch(notificacionesNoLeidasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (notificaciones.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'marcar_leidas') {
                  for (var notif in notificaciones.where((n) => !n.leida)) {
                    await ref
                        .read(notificacionesProvider.notifier)
                        .marcarComoLeida(notif.id);
                  }
                } else if (value == 'limpiar') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Limpiar notificaciones'),
                      content: const Text(
                        '¿Estás seguro de eliminar todas las notificaciones?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(notificacionesProvider.notifier)
                        .limpiarTodas();
                  }
                }
              },
              itemBuilder: (context) => [
                if (noLeidas > 0)
                  const PopupMenuItem(
                    value: 'marcar_leidas',
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(width: 8),
                        Text('Marcar todas como leídas'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'limpiar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep),
                      SizedBox(width: 8),
                      Text('Limpiar todas'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: notificaciones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No tienes notificaciones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí aparecerán las actualizaciones importantes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notificaciones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notificacion = notificaciones[index];
                return NotificacionCard(
                  notificacion: notificacion,
                  onTap: () async {
                    // Marcar como leída
                    if (!notificacion.leida) {
                      await ref
                          .read(notificacionesProvider.notifier)
                          .marcarComoLeida(notificacion.id);
                    }

                    // Navegar según el tipo
                    if (notificacion.rifaId != null) {
                      // TODO: Navegar a la rifa correspondiente
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar notificación'),
                        content: const Text(
                          '¿Estás seguro de eliminar esta notificación?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(notificacionesProvider.notifier)
                          .eliminar(notificacion.id);
                    }
                  },
                );
              },
            ),
    );
  }
}
