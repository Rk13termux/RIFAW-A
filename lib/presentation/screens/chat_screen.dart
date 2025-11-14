import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/chat_provider.dart';
import '../widgets/mensaje_bubble.dart';
import '../../core/theme/app_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? conversacionId;
  final String? rifaId;
  final String? adminId;

  const ChatScreen({
    super.key,
    this.conversacionId,
    this.rifaId,
    this.adminId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentConversacionId;

  @override
  void initState() {
    super.initState();
    _currentConversacionId = widget.conversacionId;
    
    // Si no hay conversacionId, crear una nueva
    if (_currentConversacionId == null && widget.rifaId != null && widget.adminId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _iniciarConversacion();
      });
    }
  }

  Future<void> _iniciarConversacion() async {
    if (widget.rifaId == null || widget.adminId == null) return;

    await ref.read(chatProvider.notifier).iniciarConversacion(
          rifaId: widget.rifaId!,
          adminId: widget.adminId!,
        );

    final conversacion = ref.read(chatProvider).conversacionActual;
    if (conversacion != null) {
      setState(() {
        _currentConversacionId = conversacion.id;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentConversacionId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final mensajesAsync = ref.watch(mensajesProvider(_currentConversacionId!));
    final chatState = ref.watch(chatProvider);

    // Marcar mensajes como leídos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).marcarComoLeido(_currentConversacionId!);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat con Admin'),
            Text(
              'Soporte Rifas W&A',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: mensajesAsync.when(
              data: (mensajes) {
                if (mensajes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay mensajes',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Inicia la conversación',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll al final cuando llegan nuevos mensajes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje = mensajes[index];
                    return MensajeBubble(
                      mensaje: mensaje,
                      isCliente: true,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),

          // Indicador de escritura (si el admin está escribiendo)
          // Nota: Para implementar esto necesitarías Supabase Presence
          
          // Error si hay
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Campo de entrada
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botón imagen
                  IconButton(
                    icon: const Icon(Icons.image),
                    color: AppTheme.primaryColor,
                    onPressed: chatState.isSending
                        ? null
                        : () => _seleccionarImagen(),
                  ),

                  // Campo de texto
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !chatState.isSending,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botón enviar
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: chatState.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _enviarMensaje,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarMensaje() async {
    final texto = _messageController.text.trim();
    if (texto.isEmpty || _currentConversacionId == null) return;

    _messageController.clear();

    await ref.read(chatProvider.notifier).enviarTexto(
          _currentConversacionId!,
          texto,
        );
  }

  Future<void> _seleccionarImagen() async {
    if (_currentConversacionId == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _enviarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _enviarImagen(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarImagen(ImageSource source) async {
    if (_currentConversacionId == null) return;

    await ref.read(chatProvider.notifier).enviarImagen(
          _currentConversacionId!,
          source,
        );
  }
}
