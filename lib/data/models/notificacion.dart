class NotificacionModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String? tipo;
  final String? rifaId;
  final DateTime fecha;
  final bool leida;

  NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    this.tipo,
    this.rifaId,
    required this.fecha,
    required this.leida,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      tipo: json['tipo'] as String?,
      rifaId: json['rifa_id'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      leida: json['leida'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'rifa_id': rifaId,
      'fecha': fecha.toIso8601String(),
      'leida': leida,
    };
  }

  NotificacionModel copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    String? tipo,
    String? rifaId,
    DateTime? fecha,
    bool? leida,
  }) {
    return NotificacionModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      rifaId: rifaId ?? this.rifaId,
      fecha: fecha ?? this.fecha,
      leida: leida ?? this.leida,
    );
  }
}
