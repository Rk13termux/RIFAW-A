import '../../services/supabase_client.dart';
import '../models/rifa.dart';

class RifaRepository {
  final _supabase = SupabaseClientService.client;

  // Obtener rifas activas
  Future<List<Rifa>> getRifasActivas() async {
    try {
      final response = await _supabase
          .from('rifas')
          .select()
          .in_('estado', ['activa', 'vendiendo'])
          .order('created_at', ascending: false);

      return (response as List).map((json) => Rifa.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener rifas: $e');
    }
  }

  // Obtener una rifa por ID
  Future<Rifa?> getRifaById(String id) async {
    try {
      final response = await _supabase
          .from('rifas')
          .select()
          .eq('id', id)
          .single();

      return Rifa.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener rifa: $e');
    }
  }

  // Stream de rifas activas (realtime)
  Stream<List<Rifa>> watchRifasActivas() {
    return _supabase
        .from('rifas')
        .stream(primaryKey: ['id'])
        .inFilter('estado', ['activa', 'vendiendo'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Rifa.fromJson(json)).toList());
  }

  // Stream de una rifa específica
  Stream<Rifa?> watchRifa(String rifaId) {
    return _supabase
        .from('rifas')
        .stream(primaryKey: ['id'])
        .eq('id', rifaId)
        .map((data) {
          if (data.isEmpty) return null;
          return Rifa.fromJson(data.first);
        });
  }
}
