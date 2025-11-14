class Boleto {
  final String id;
  final String rifaId;
  final int numero;
  final String? clienteId;
  final String? nombreCliente;
  final String? telefono;
  final DateTime? fechaCompra;
  final String estado;

  Boleto({
    required this.id,
    required this.rifaId,
    required this.numero,
    this.clienteId,
    this.nombreCliente,
    this.telefono,
    this.fechaCompra,
    required this.estado,
  });

  factory Boleto.fromJson(Map<String, dynamic> json) {
    return Boleto(
      id: json['id'] as String,
      rifaId: json['rifa_id'] as String,
      numero: json['numero'] as int,
      clienteId: json['cliente_id'] as String?,
      nombreCliente: json['nombre_cliente'] as String?,
      telefono: json['telefono'] as String?,
      fechaCompra: json['fecha_compra'] != null 
          ? DateTime.parse(json['fecha_compra'] as String) 
          : null,
      estado: json['estado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rifa_id': rifaId,
      'numero': numero,
      'cliente_id': clienteId,
      'nombre_cliente': nombreCliente,
      'telefono': telefono,
      'fecha_compra': fechaCompra?.toIso8601String(),
      'estado': estado,
    };
  }

  Boleto copyWith({
    String? id,
    String? rifaId,
    int? numero,
    String? clienteId,
    String? nombreCliente,
    String? telefono,
    DateTime? fechaCompra,
    String? estado,
  }) {
    return Boleto(
      id: id ?? this.id,
      rifaId: rifaId ?? this.rifaId,
      numero: numero ?? this.numero,
      clienteId: clienteId ?? this.clienteId,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      telefono: telefono ?? this.telefono,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      estado: estado ?? this.estado,
    );
  }
}
