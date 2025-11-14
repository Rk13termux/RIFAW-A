class AppConstants {
  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Estados de rifas
  static const String rifaActiva = 'activa';
  static const String rifaVendiendo = 'vendiendo';
  static const String rifaSorteada = 'sorteada';
  static const String rifaFinalizada = 'finalizada';
  
  // Estados de boletos
  static const String boletoDisponible = 'disponible';
  static const String boletoApartado = 'apartado';
  static const String boletoVendido = 'vendido';
  static const String boletoGanador = 'ganador';
  
  // Tipos de emisor en chat
  static const String emisorCliente = 'cliente';
  static const String emisorAdmin = 'admin';
  static const String emisorAi = 'ai';
  
  // Grid
  static const int totalNumeros = 100;
  static const int numerosPerRow = 10;
  
  // Notifications
  static const String notificationChannelId = 'rifaswa_channel';
  static const String notificationChannelName = 'Rifas W&A';
  static const String notificationChannelDescription = 'Notificaciones de rifas, boletos y mensajes';
}
