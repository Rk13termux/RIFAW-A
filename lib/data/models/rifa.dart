class Rifa {
  final String id;
  final String adminId;
  final String titulo;
  final String premio;
  final String? descripcion;
  final double precioBoleto;
  final int totalBoletos;
  final DateTime? fechaSorteo;
  final String? imagenUrl;
  final String estado;
  final DateTime? createdAt;

  Rifa({
    required this.id,
    required this.adminId,
    required this.titulo,
    required this.premio,
    this.descripcion,
    required this.precioBoleto,
    required this.totalBoletos,
    this.fechaSorteo,
    this.imagenUrl,
    required this.estado,
    this.createdAt,
  });

  factory Rifa.fromJson(Map<String, dynamic> json) {
    return Rifa(
      id: json['id'] as String,
      adminId: json['admin_id'] as String,
      titulo: json['titulo'] as String,
      premio: json['premio'] as String,
      descripcion: json['descripcion'] as String?,
      precioBoleto: (json['precio_boleto'] as num).toDouble(),
      totalBoletos: json['total_boletos'] as int,
      fechaSorteo: json['fecha_sorteo'] != null 
          ? DateTime.parse(json['fecha_sorteo'] as String) 
          : null,
      imagenUrl: json['imagen_url'] as String?,
      estado: json['estado'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'titulo': titulo,
      'premio': premio,
      'descripcion': descripcion,
      'precio_boleto': precioBoleto,
      'total_boletos': totalBoletos,
      'fecha_sorteo': fechaSorteo?.toIso8601String(),
      'imagen_url': imagenUrl,
      'estado': estado,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Rifa copyWith({
    String? id,
    String? adminId,
    String? titulo,
    String? premio,
    String? descripcion,
    double? precioBoleto,
    int? totalBoletos,
    DateTime? fechaSorteo,
    String? imagenUrl,
    String? estado,
    DateTime? createdAt,
  }) {
    return Rifa(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      titulo: titulo ?? this.titulo,
      premio: premio ?? this.premio,
      descripcion: descripcion ?? this.descripcion,
      precioBoleto: precioBoleto ?? this.precioBoleto,
      totalBoletos: totalBoletos ?? this.totalBoletos,
      fechaSorteo: fechaSorteo ?? this.fechaSorteo,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
