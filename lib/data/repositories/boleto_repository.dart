import '../../services/supabase_client.dart';
import '../models/boleto.dart';

class BoletoRepository {
  final _supabase = SupabaseClientService.client;

  // Obtener boletos de una rifa
  Future<List<Boleto>> getBoletosByRifa(String rifaId) async {
    try {
      final response = await _supabase
          .from('boletos')
          .select()
          .eq('rifa_id', rifaId)
          .order('numero', ascending: true);

      return (response as List).map((json) => Boleto.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener boletos: $e');
    }
  }

  // Obtener boletos del cliente actual
  Future<List<Boleto>> getMisBoletos() async {
    try {
      final userId = SupabaseClientService.instance.currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('boletos')
          .select()
          .eq('cliente_id', userId)
          .order('fecha_compra', ascending: false);

      return (response as List).map((json) => Boleto.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mis boletos: $e');
    }
  }

  // Apartar un boleto
  Future<Boleto> apartarBoleto({
    required String rifaId,
    required int numero,
    required String nombreCliente,
    required String telefono,
  }) async {
    try {
      final userId = SupabaseClientService.instance.currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase.from('boletos').insert({
        'rifa_id': rifaId,
        'numero': numero,
        'cliente_id': userId,
        'nombre_cliente': nombreCliente,
        'telefono': telefono,
        'estado': 'apartado',
        'fecha_compra': DateTime.now().toIso8601String(),
      }).select().single();

      return Boleto.fromJson(response);
    } catch (e) {
      throw Exception('Error al apartar boleto: $e');
    }
  }

  // Actualizar estado de boleto
  Future<void> actualizarEstado(String boletoId, String nuevoEstado) async {
    try {
      await _supabase
          .from('boletos')
          .update({'estado': nuevoEstado})
          .eq('id', boletoId);
    } catch (e) {
      throw Exception('Error al actualizar boleto: $e');
    }
  }

  // Stream de boletos de una rifa (realtime)
  Stream<List<Boleto>> watchBoletosByRifa(String rifaId) {
    return _supabase
        .from('boletos')
        .stream(primaryKey: ['id'])
        .eq('rifa_id', rifaId)
        .order('numero', ascending: true)
        .map((data) => data.map((json) => Boleto.fromJson(json)).toList());
  }

  // Stream de mis boletos
  Stream<List<Boleto>> watchMisBoletos() {
    final userId = SupabaseClientService.instance.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('boletos')
        .stream(primaryKey: ['id'])
        .eq('cliente_id', userId)
        .order('fecha_compra', ascending: false)
        .map((data) => data.map((json) => Boleto.fromJson(json)).toList());
  }
}
