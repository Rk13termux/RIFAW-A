import 'package:flutter/material.dart';
import '../../data/models/boleto.dart';
import '../../core/utils/helpers.dart';
import '../../core/theme/app_theme.dart';

class BoletoCard extends StatelessWidget {
  final Boleto boleto;
  final VoidCallback? onChatTap;

  const BoletoCard({
    super.key,
    required this.boleto,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Número del boleto
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.getBoletoColor(boleto.estado).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.getBoletoColor(boleto.estado),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  boleto.numero.toString().padLeft(3, '0'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getBoletoColor(boleto.estado),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boleto.nombreCliente ?? 'Sin nombre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    boleto.telefono ?? 'Sin teléfono',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getEstadoIcon(boleto.estado),
                        size: 16,
                        color: AppTheme.getBoletoColor(boleto.estado),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getEstadoTexto(boleto.estado),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getBoletoColor(boleto.estado),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateHelper.formatDate(boleto.fechaCompra),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botón chat
            if (onChatTap != null)
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                color: AppTheme.primaryColor,
                onPressed: onChatTap,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'apartado':
        return Icons.bookmark;
      case 'vendido':
        return Icons.check_circle;
      case 'ganador':
        return Icons.emoji_events;
      default:
        return Icons.help;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'apartado':
        return 'Apartado';
      case 'vendido':
        return 'Vendido';
      case 'ganador':
        return '¡GANADOR!';
      default:
        return estado;
    }
  }
}
