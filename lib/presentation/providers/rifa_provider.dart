import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/rifa_repository.dart';
import '../../data/models/rifa.dart';

// Repository provider
final rifaRepositoryProvider = Provider((ref) => RifaRepository());

// Rifas activas provider (stream)
final rifasActivasProvider = StreamProvider<List<Rifa>>((ref) {
  final repository = ref.watch(rifaRepositoryProvider);
  return repository.watchRifasActivas();
});

// Rifa individual provider
final rifaProvider = StreamProvider.family<Rifa?, String>((ref, rifaId) {
  final repository = ref.watch(rifaRepositoryProvider);
  return repository.watchRifa(rifaId);
});

// Estado de carga manual
final rifasListProvider = FutureProvider<List<Rifa>>((ref) async {
  final repository = ref.watch(rifaRepositoryProvider);
  return repository.getRifasActivas();
});
