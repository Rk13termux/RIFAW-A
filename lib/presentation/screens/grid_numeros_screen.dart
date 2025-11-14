import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/boleto.dart';
import '../providers/boleto_provider.dart';
import '../providers/rifa_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

class GridNumerosScreen extends ConsumerStatefulWidget {
  final String rifaId;

  const GridNumerosScreen({
    super.key,
    required this.rifaId,
  });

  @override
  ConsumerState<GridNumerosScreen> createState() => _GridNumerosScreenState();
}

class _GridNumerosScreenState extends ConsumerState<GridNumerosScreen> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rifaAsync = ref.watch(rifaProvider(widget.rifaId));
    final boletosAsync = ref.watch(boletosRifaProvider(widget.rifaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu número'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _mostrarLeyenda(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la rifa
          rifaAsync.when(
            data: (rifa) => rifa != null
                ? Container(
                    width: double.infinity,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          rifa.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monetization_on, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              CurrencyHelper.format(rifa.precioBoleto),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),

          // Leyenda de colores
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLeyendaItem('Disponible', AppTheme.disponibleColor),
                _buildLeyendaItem('Apartado', AppTheme.apartadoColor),
                _buildLeyendaItem('Vendido', AppTheme.vendidoColor),
                _buildLeyendaItem('Ganador', AppTheme.ganadorColor),
              ],
            ),
          ),

          // Grid de números
          Expanded(
            child: boletosAsync.when(
              data: (boletos) => _buildGrid(boletos),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Boleto> boletos) {
    // Crear mapa de números con sus boletos
    final Map<int, Boleto?> numerosMap = {};
    for (int i = 1; i <= AppConstants.totalNumeros; i++) {
      numerosMap[i] = null;
    }
    
    for (var boleto in boletos) {
      numerosMap[boleto.numero] = boleto;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppConstants.numerosPerRow,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: AppConstants.totalNumeros,
      itemBuilder: (context, index) {
        final numero = index + 1;
        final boleto = numerosMap[numero];
        
        return _buildNumeroItem(numero, boleto);
      },
    );
  }

  Widget _buildNumeroItem(int numero, Boleto? boleto) {
    final estado = boleto?.estado ?? AppConstants.boletoDisponible;
    final color = AppTheme.getBoletoColor(estado);
    final isDisponible = estado == AppConstants.boletoDisponible;

    return InkWell(
      onTap: isDisponible ? () => _mostrarModalApartar(numero) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                numero.toString().padLeft(3, '0'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (!isDisponible)
                Icon(
                  _getEstadoIcon(estado),
                  size: 16,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeyendaItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case AppConstants.boletoApartado:
        return Icons.bookmark;
      case AppConstants.boletoVendido:
        return Icons.check_circle;
      case AppConstants.boletoGanador:
        return Icons.emoji_events;
      default:
        return Icons.help;
    }
  }

  void _mostrarLeyenda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leyenda de Estados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeyendaCompleta(
              'Disponible',
              AppTheme.disponibleColor,
              'El número está disponible para apartar',
            ),
            const SizedBox(height: 12),
            _buildLeyendaCompleta(
              'Apartado',
              AppTheme.apartadoColor,
              'El número ha sido apartado',
            ),
            const SizedBox(height: 12),
            _buildLeyendaCompleta(
              'Vendido',
              AppTheme.vendidoColor,
              'El número ha sido pagado y confirmado',
            ),
            const SizedBox(height: 12),
            _buildLeyendaCompleta(
              'Ganador',
              AppTheme.ganadorColor,
              'Este número resultó ganador',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeyendaCompleta(String label, Color color, String descripcion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                descripcion,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarModalApartar(int numero) {
    _nombreController.clear();
    _telefonoController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Número seleccionado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Número seleccionado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      numero.toString().padLeft(3, '0'),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: ValidationHelper.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (10 dígitos)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: ValidationHelper.validatePhone,
              ),
              const SizedBox(height: 24),

              // Botón apartar
              Consumer(
                builder: (context, ref, child) {
                  final apartarState = ref.watch(apartarBoletoProvider);

                  return ElevatedButton(
                    onPressed: apartarState.isLoading
                        ? null
                        : () => _apartarBoleto(context, ref, numero),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: apartarState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Apartar Boleto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _apartarBoleto(BuildContext context, WidgetRef ref, int numero) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(apartarBoletoProvider.notifier).apartarBoleto(
          rifaId: widget.rifaId,
          numero: numero,
          nombreCliente: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Boleto #${numero.toString().padLeft(3, '0')} apartado!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver mis boletos',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/mis-boletos');
            },
          ),
        ),
      );
      ref.read(apartarBoletoProvider.notifier).reset();
    } else {
      final error = ref.read(apartarBoletoProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al apartar boleto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
