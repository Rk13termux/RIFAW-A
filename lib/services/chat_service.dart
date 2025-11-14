import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_client.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/mensaje.dart';
import '../data/models/conversacion.dart';

class ChatService {
  final ChatRepository _chatRepository = ChatRepository();
  final _supabase = SupabaseClientService.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Obtener o crear conversación
  Future<Conversacion> iniciarConversacion({
    required String rifaId,
    required String adminId,
  }) async {
    return await _chatRepository.getOrCreateConversacion(
      rifaId: rifaId,
      adminId: adminId,
    );
  }

  // Enviar mensaje de texto
  Future<Mensaje> enviarTexto({
    required String conversacionId,
    required String texto,
  }) async {
    if (texto.trim().isEmpty) {
      throw Exception('El mensaje no puede estar vacío');
    }

    return await _chatRepository.enviarMensaje(
      conversacionId: conversacionId,
      texto: texto,
    );
  }

  // Seleccionar y enviar imagen
  Future<Mensaje?> enviarImagen({
    required String conversacionId,
    required ImageSource source,
  }) async {
    try {
      // Seleccionar imagen
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Leer bytes de la imagen
      final bytes = await pickedFile.readAsBytes();
      
      // Generar nombre único
      final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'chat_images/$fileName';

      // Subir a Supabase Storage
      final imageUrl = await SupabaseClientService.instance.uploadImage(
        'rifas',
        path,
        bytes,
      );

      // Enviar mensaje con imagen
      return await _chatRepository.enviarMensaje(
        conversacionId: conversacionId,
        imagenUrl: imageUrl,
        texto: null,
      );
    } catch (e) {
      throw Exception('Error al enviar imagen: $e');
    }
  }

  // Obtener mensajes
  Future<List<Mensaje>> obtenerMensajes(String conversacionId) async {
    return await _chatRepository.getMensajes(conversacionId);
  }

  // Stream de mensajes (realtime)
  Stream<List<Mensaje>> escucharMensajes(String conversacionId) {
    return _chatRepository.watchMensajes(conversacionId);
  }

  // Marcar mensajes como leídos
  Future<void> marcarComoLeido(String conversacionId) async {
    await _chatRepository.marcarComoLeido(conversacionId);
  }

  // Obtener conversaciones del cliente
  Future<List<Conversacion>> obtenerConversaciones() async {
    return await _chatRepository.getMisConversaciones();
  }

  // Stream de conversaciones
  Stream<List<Conversacion>> escucharConversaciones() {
    return _chatRepository.watchMisConversaciones();
  }

  // Verificar si hay nuevos mensajes
  Future<bool> hayMensajesNuevos(String conversacionId) async {
    try {
      final response = await _supabase
          .from('mensajes')
          .select()
          .eq('conversacion_id', conversacionId)
          .eq('leido', false)
          .neq('emisor', 'cliente');

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Contar mensajes no leídos por conversación
  Future<int> contarMensajesNoLeidos(String conversacionId) async {
    try {
      final response = await _supabase
          .from('mensajes')
          .select()
          .eq('conversacion_id', conversacionId)
          .eq('leido', false)
          .neq('emisor', 'cliente');

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Total de mensajes no leídos
  Future<int> contarTotalMensajesNoLeidos() async {
    try {
      final userId = SupabaseClientService.instance.currentUserId;
      if (userId == null) return 0;

      // Obtener todas las conversaciones del cliente
      final conversaciones = await _chatRepository.getMisConversaciones();
      
      int total = 0;
      for (var conv in conversaciones) {
        total += await contarMensajesNoLeidos(conv.id);
      }
      
      return total;
    } catch (e) {
      return 0;
    }
  }
}
