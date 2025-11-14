import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/rifa_detail_screen.dart';
import '../screens/grid_numeros_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/mis_boletos_screen.dart';
import '../screens/notificaciones_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/rifa/:id',
      name: 'rifa-detail',
      builder: (context, state) {
        final rifaId = state.pathParameters['id']!;
        return RifaDetailScreen(rifaId: rifaId);
      },
    ),
    GoRoute(
      path: '/rifa/:id/numeros',
      name: 'grid-numeros',
      builder: (context, state) {
        final rifaId = state.pathParameters['id']!;
        return GridNumerosScreen(rifaId: rifaId);
      },
    ),
    GoRoute(
      path: '/chat/:conversacionId',
      name: 'chat',
      builder: (context, state) {
        final conversacionId = state.pathParameters['conversacionId']!;
        final rifaId = state.uri.queryParameters['rifaId'];
        final adminId = state.uri.queryParameters['adminId'];
        
        return ChatScreen(
          conversacionId: conversacionId,
          rifaId: rifaId,
          adminId: adminId,
        );
      },
    ),
    GoRoute(
      path: '/mis-boletos',
      name: 'mis-boletos',
      builder: (context, state) => const MisBoletosScreen(),
    ),
    GoRoute(
      path: '/notificaciones',
      name: 'notificaciones',
      builder: (context, state) => const NotificacionesScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Text('Página no encontrada: ${state.uri}'),
    ),
  ),
);
