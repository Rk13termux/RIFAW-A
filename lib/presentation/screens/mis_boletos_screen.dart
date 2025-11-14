import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/boleto_provider.dart';
import '../widgets/boleto_card.dart';

class MisBoletosScreen extends ConsumerWidget {
  const MisBoletosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boletosAsync = ref.watch(misBoletosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Boletos'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(misBoletosProvider);
        },
        child: boletosAsync.when(
          data: (boletos) {
            if (boletos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes boletos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Participa en una rifa para apartar tus números',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.celebration),
                      label: const Text('Ver Rifas'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: boletos.length,
              itemBuilder: (context, index) {
                final boleto = boletos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BoletoCard(
                    boleto: boleto,
                    onChatTap: () {
                      // TODO: Obtener el adminId de la rifa
                      context.push(
                        '/chat/new?rifaId=${boleto.rifaId}&adminId=ADMIN_ID',
                      );
                    },
                  ),
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
                const Text(
                  'Error al cargar boletos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(misBoletosProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
