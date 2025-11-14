import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/rifa_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/rifa_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rifasAsync = ref.watch(rifasActivasProvider);
    final notificacionesNoLeidas = ref.watch(notificacionesNoLeidasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rifas W&A'),
        actions: [
          // Notificaciones
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => context.push('/notificaciones'),
              ),
              if (notificacionesNoLeidas > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notificacionesNoLeidas > 9 ? '9+' : '$notificacionesNoLeidas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          // Mis boletos
          IconButton(
            icon: const Icon(Icons.confirmation_number),
            onPressed: () => context.push('/mis-boletos'),
          ),
        ],
      ),
      body: rifasAsync.when(
        data: (rifas) {
          if (rifas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay rifas activas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(rifasActivasProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Carrusel destacado
                if (rifas.length > 3)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Rifas Destacadas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CarouselSlider.builder(
                          itemCount: rifas.length > 5 ? 5 : rifas.length,
                          itemBuilder: (context, index, realIndex) {
                            final rifa = rifas[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: RifaCard(
                                rifa: rifa,
                                onTap: () => context.push('/rifa/${rifa.id}'),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 280,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.85,
                            autoPlayInterval: const Duration(seconds: 4),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                // Título de todas las rifas
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Todas las Rifas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Grid de rifas
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final rifa = rifas[index];
                        return RifaCard(
                          rifa: rifa,
                          onTap: () => context.push('/rifa/${rifa.id}'),
                        );
                      },
                      childCount: rifas.length,
                    ),
                  ),
                ),
                
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(rifasActivasProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
