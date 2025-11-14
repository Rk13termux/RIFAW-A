import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/boleto_repository.dart';
import '../../data/models/boleto.dart';

// Repository provider
final boletoRepositoryProvider = Provider((ref) => BoletoRepository());

// Boletos por rifa (stream)
final boletosRifaProvider = StreamProvider.family<List<Boleto>, String>((ref, rifaId) {
  final repository = ref.watch(boletoRepositoryProvider);
  return repository.watchBoletosByRifa(rifaId);
});

// Mis boletos (stream)
final misBoletosProvider = StreamProvider<List<Boleto>>((ref) {
  final repository = ref.watch(boletoRepositoryProvider);
  return repository.watchMisBoletos();
});

// Estado de apartado (para controlar el proceso)
class ApartarBoletoState {
  final bool isLoading;
  final String? error;
  final Boleto? boleto;

  ApartarBoletoState({
    this.isLoading = false,
    this.error,
    this.boleto,
  });

  ApartarBoletoState copyWith({
    bool? isLoading,
    String? error,
    Boleto? boleto,
  }) {
    return ApartarBoletoState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      boleto: boleto ?? this.boleto,
    );
  }
}

// Provider para apartar boleto
class ApartarBoletoNotifier extends StateNotifier<ApartarBoletoState> {
  final BoletoRepository _repository;

  ApartarBoletoNotifier(this._repository) : super(ApartarBoletoState());

  Future<bool> apartarBoleto({
    required String rifaId,
    required int numero,
    required String nombreCliente,
    required String telefono,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final boleto = await _repository.apartarBoleto(
        rifaId: rifaId,
        numero: numero,
        nombreCliente: nombreCliente,
        telefono: telefono,
      );

      state = state.copyWith(isLoading: false, boleto: boleto);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = ApartarBoletoState();
  }
}

final apartarBoletoProvider = StateNotifierProvider<ApartarBoletoNotifier, ApartarBoletoState>((ref) {
  final repository = ref.watch(boletoRepositoryProvider);
  return ApartarBoletoNotifier(repository);
});
