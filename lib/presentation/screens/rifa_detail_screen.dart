import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/rifa_provider.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';

class RifaDetailScreen extends ConsumerWidget {
  final String rifaId;

  const RifaDetailScreen({
    super.key,
    required this.rifaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rifaAsync = ref.watch(rifaProvider(rifaId));

    return Scaffold(
      body: rifaAsync.when(
        data: (rifa) {
          if (rifa == null) {
            return const Center(
              child: Text('Rifa no encontrada'),
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar con imagen
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    rifa.titulo,
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  background: rifa.imagenUrl != null
                      ? CachedNetworkImage(
                          imageUrl: rifa.imagenUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, size: 64),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 64),
                        ),
                ),
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Premio
                      Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Premio',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      rifa.premio,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      if (rifa.descripcion != null) ...[
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rifa.descripcion!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Detalles
                      const Text(
                        'Detalles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDetailRow(
                        Icons.monetization_on,
                        'Precio por boleto',
                        CurrencyHelper.format(rifa.precioBoleto),
                      ),
                      _buildDetailRow(
                        Icons.confirmation_number,
                        'Total de boletos',
                        '${rifa.totalBoletos}',
                      ),
                      if (rifa.fechaSorteo != null)
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Fecha del sorteo',
                          DateHelper.formatDateTime(rifa.fechaSorteo),
                        ),
                      _buildDetailRow(
                        Icons.info,
                        'Estado',
                        _getEstadoTexto(rifa.estado),
                        color: _getEstadoColor(rifa.estado),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: rifaAsync.maybeWhen(
        data: (rifa) => rifa != null
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => context.push('/rifa/$rifaId/numeros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Ver Números'),
                  ),
                ),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'activa':
        return 'Activa';
      case 'vendiendo':
        return 'En venta';
      case 'sorteada':
        return 'Sorteada';
      case 'finalizada':
        return 'Finalizada';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'activa':
      case 'vendiendo':
        return Colors.green;
      case 'sorteada':
        return Colors.blue;
      case 'finalizada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
