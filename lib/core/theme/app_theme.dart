import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  // Colores de estados de boletos
  static const Color disponibleColor = Colors.grey;
  static const Color apartadoColor = Colors.amber;
  static const Color vendidoColor = Colors.green;
  static const Color ganadorColor = Colors.red;
  
  // Chat colors
  static const Color clienteBubbleColor = Color(0xFFE3F2FD);
  static const Color adminBubbleColor = Color(0xFFF1F8E9);
  static const Color aiBubbleColor = Color(0xFFFFF3E0);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
  
  static Color getBoletoColor(String estado) {
    switch (estado) {
      case 'disponible':
        return disponibleColor;
      case 'apartado':
        return apartadoColor;
      case 'vendido':
        return vendidoColor;
      case 'ganador':
        return ganadorColor;
      default:
        return disponibleColor;
    }
  }
  
  static Color getChatBubbleColor(String emisor) {
    switch (emisor) {
      case 'cliente':
        return clienteBubbleColor;
      case 'admin':
        return adminBubbleColor;
      case 'ai':
        return aiBubbleColor;
      default:
        return clienteBubbleColor;
    }
  }
}
