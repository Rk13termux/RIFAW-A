import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/chat_service.dart';
import '../../data/models/mensaje.dart';
import '../../data/models/conversacion.dart';

// Service provider
final chatServiceProvider = Provider((ref) => ChatService());

// Mensajes de una conversación (stream)
final mensajesProvider = StreamProvider.family<List<Mensaje>, String>((ref, conversacionId) {
  final service = ref.watch(chatServiceProvider);
  return service.escucharMensajes(conversacionId);
});

// Conversaciones del cliente (stream)
final conversacionesProvider = StreamProvider<List<Conversacion>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return service.escucharConversaciones();
});

// Estado del chat
class ChatState {
  final bool isLoading;
  final bool isSending;
  final String? error;
  final Conversacion? conversacionActual;

  ChatState({
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.conversacionActual,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    String? error,
    Conversacion? conversacionActual,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
      conversacionActual: conversacionActual ?? this.conversacionActual,
    );
  }
}

// Chat notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;

  ChatNotifier(this._chatService) : super(ChatState());

  Future<void> iniciarConversacion({
    required String rifaId,
    required String adminId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final conversacion = await _chatService.iniciarConversacion(
        rifaId: rifaId,
        adminId: adminId,
      );

      state = state.copyWith(
        isLoading: false,
        conversacionActual: conversacion,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> enviarTexto(String conversacionId, String texto) async {
    if (texto.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      await _chatService.enviarTexto(
        conversacionId: conversacionId,
        texto: texto,
      );

      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> enviarImagen(String conversacionId, ImageSource source) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      await _chatService.enviarImagen(
        conversacionId: conversacionId,
        source: source,
      );

      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> marcarComoLeido(String conversacionId) async {
    try {
      await _chatService.marcarComoLeido(conversacionId);
    } catch (e) {
      // Silently fail
    }
  }

  void reset() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final service = ref.watch(chatServiceProvider);
  return ChatNotifier(service);
});

// Contador de mensajes no leídos
final mensajesNoLeidosProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(chatServiceProvider);
  return service.contarTotalMensajesNoLeidos();
});
