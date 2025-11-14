import '../../services/supabase_client.dart';
import '../models/conversacion.dart';
import '../models/mensaje.dart';

class ChatRepository {
  final _supabase = SupabaseClientService.client;

  // Obtener o crear conversación
  Future<Conversacion> getOrCreateConversacion({
    required String rifaId,
    required String adminId,
  }) async {
    try {
      final userId = SupabaseClientService.instance.currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Buscar conversación existente
      final existing = await _supabase
          .from('conversaciones')
          .select()
          .eq('rifa_id', rifaId)
          .eq('cliente_id', userId)
          .maybeSingle();

      if (existing != null) {
        return Conversacion.fromJson(existing);
      }

      // Crear nueva conversación
      final response = await _supabase.from('conversaciones').insert({
        'rifa_id': rifaId,
        'cliente_id': userId,
        'admin_id': adminId,
        'visto_cliente': true,
        'visto_admin': false,
      }).select().single();

      return Conversacion.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener/crear conversación: $e');
    }
  }

  // Obtener mensajes de una conversación
  Future<List<Mensaje>> getMensajes(String conversacionId) async {
    try {
      final response = await _supabase
          .from('mensajes')
          .select()
          .eq('conversacion_id', conversacionId)
          .order('fecha', ascending: true);

      return (response as List).map((json) => Mensaje.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  // Enviar mensaje
  Future<Mensaje> enviarMensaje({
    required String conversacionId,
    String? texto,
    String? imagenUrl,
  }) async {
    try {
      final response = await _supabase.from('mensajes').insert({
        'conversacion_id': conversacionId,
        'emisor': 'cliente',
        'texto': texto,
        'imagen_url': imagenUrl,
        'fecha': DateTime.now().toIso8601String(),
        'leido': false,
      }).select().single();

      // Actualizar último mensaje en conversación
      await _supabase.from('conversaciones').update({
        'ultimo_mensaje': texto ?? '[Imagen]',
        'visto_admin': false,
        'visto_cliente': true,
      }).eq('id', conversacionId);

      return Mensaje.fromJson(response);
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  // Marcar mensajes como leídos
  Future<void> marcarComoLeido(String conversacionId) async {
    try {
      await _supabase
          .from('mensajes')
          .update({'leido': true})
          .eq('conversacion_id', conversacionId)
          .neq('emisor', 'cliente');

      await _supabase
          .from('conversaciones')
          .update({'visto_cliente': true})
          .eq('id', conversacionId);
    } catch (e) {
      throw Exception('Error al marcar como leído: $e');
    }
  }

  // Stream de mensajes (realtime)
  Stream<List<Mensaje>> watchMensajes(String conversacionId) {
    return _supabase
        .from('mensajes')
        .stream(primaryKey: ['id'])
        .eq('conversacion_id', conversacionId)
        .order('fecha', ascending: true)
        .map((data) => data.map((json) => Mensaje.fromJson(json)).toList());
  }

  // Obtener conversaciones del cliente
  Future<List<Conversacion>> getMisConversaciones() async {
    try {
      final userId = SupabaseClientService.instance.currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('conversaciones')
          .select()
          .eq('cliente_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Conversacion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener conversaciones: $e');
    }
  }

  // Stream de conversaciones
  Stream<List<Conversacion>> watchMisConversaciones() {
    final userId = SupabaseClientService.instance.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('conversaciones')
        .stream(primaryKey: ['id'])
        .eq('cliente_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Conversacion.fromJson(json)).toList());
  }
}
