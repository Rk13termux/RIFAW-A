import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import '../../data/models/notificacion.dart';

// Service provider
final notificationServiceProvider = Provider((ref) => NotificationService());

// Provider para lista de notificaciones
final notificacionesProvider = StateNotifierProvider<NotificacionesNotifier, List<NotificacionModel>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificacionesNotifier(service);
});

class NotificacionesNotifier extends StateNotifier<List<NotificacionModel>> {
  final NotificationService _service;

  NotificacionesNotifier(this._service) : super(_service.notifications);

  void refresh() {
    state = _service.notifications;
  }

  Future<void> marcarComoLeida(String notificationId) async {
    await _service.marcarComoLeida(notificationId);
    refresh();
  }

  Future<void> eliminar(String notificationId) async {
    await _service.eliminarNotificacion(notificationId);
    refresh();
  }

  Future<void> limpiarTodas() async {
    await _service.limpiarTodas();
    refresh();
  }
}

// Contador de notificaciones no leídas
final notificacionesNoLeidasProvider = Provider<int>((ref) {
  final notificaciones = ref.watch(notificacionesProvider);
  return notificaciones.where((n) => !n.leida).length;
});
