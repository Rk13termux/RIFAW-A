class Conversacion {
  final String id;
  final String rifaId;
  final String clienteId;
  final String adminId;
  final String? ultimoMensaje;
  final bool vistoCliente;
  final bool vistoAdmin;
  final DateTime? createdAt;

  Conversacion({
    required this.id,
    required this.rifaId,
    required this.clienteId,
    required this.adminId,
    this.ultimoMensaje,
    required this.vistoCliente,
    required this.vistoAdmin,
    this.createdAt,
  });

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      id: json['id'] as String,
      rifaId: json['rifa_id'] as String,
      clienteId: json['cliente_id'] as String,
      adminId: json['admin_id'] as String,
      ultimoMensaje: json['ultimo_mensaje'] as String?,
      vistoCliente: json['visto_cliente'] as bool? ?? false,
      vistoAdmin: json['visto_admin'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rifa_id': rifaId,
      'cliente_id': clienteId,
      'admin_id': adminId,
      'ultimo_mensaje': ultimoMensaje,
      'visto_cliente': vistoCliente,
      'visto_admin': vistoAdmin,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Conversacion copyWith({
    String? id,
    String? rifaId,
    String? clienteId,
    String? adminId,
    String? ultimoMensaje,
    bool? vistoCliente,
    bool? vistoAdmin,
    DateTime? createdAt,
  }) {
    return Conversacion(
      id: id ?? this.id,
      rifaId: rifaId ?? this.rifaId,
      clienteId: clienteId ?? this.clienteId,
      adminId: adminId ?? this.adminId,
      ultimoMensaje: ultimoMensaje ?? this.ultimoMensaje,
      vistoCliente: vistoCliente ?? this.vistoCliente,
      vistoAdmin: vistoAdmin ?? this.vistoAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
