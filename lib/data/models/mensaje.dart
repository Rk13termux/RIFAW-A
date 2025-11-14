class Mensaje {
  final String id;
  final String conversacionId;
  final String emisor;
  final String? texto;
  final String? imagenUrl;
  final DateTime fecha;
  final bool leido;

  Mensaje({
    required this.id,
    required this.conversacionId,
    required this.emisor,
    this.texto,
    this.imagenUrl,
    required this.fecha,
    required this.leido,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as String,
      conversacionId: json['conversacion_id'] as String,
      emisor: json['emisor'] as String,
      texto: json['texto'] as String?,
      imagenUrl: json['imagen_url'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      leido: json['leido'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversacion_id': conversacionId,
      'emisor': emisor,
      'texto': texto,
      'imagen_url': imagenUrl,
      'fecha': fecha.toIso8601String(),
      'leido': leido,
    };
  }

  Mensaje copyWith({
    String? id,
    String? conversacionId,
    String? emisor,
    String? texto,
    String? imagenUrl,
    DateTime? fecha,
    bool? leido,
  }) {
    return Mensaje(
      id: id ?? this.id,
      conversacionId: conversacionId ?? this.conversacionId,
      emisor: emisor ?? this.emisor,
      texto: texto ?? this.texto,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fecha: fecha ?? this.fecha,
      leido: leido ?? this.leido,
    );
  }
}
