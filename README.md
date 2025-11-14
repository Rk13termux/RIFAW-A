# Rifas W&A - App Cliente# rifaswa_cliente



App móvil multiplataforma (Android, iOS, Web) para participar en rifas, con sincronización en tiempo real, chat con administrador y notificaciones push.A new Flutter project.



## 🚀 Características## Getting Started



- ✅ **Navegación de Rifas**: Ver rifas activas en carrusel y gridThis project is a starting point for a Flutter application.

- ✅ **Apartado de Boletos**: Selección visual de números con grid 10x10

- ✅ **Sincronización en Tiempo Real**: Actualización automática de boletos usando Supabase RealtimeA few resources to get you started if this is your first Flutter project:

- ✅ **Chat con Admin**: Mensajes de texto e imágenes, con respuestas manuales o AI

- ✅ **Notificaciones Push**: Recibir alertas de rifas, sorteos y mensajes- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

- ✅ **Mis Boletos**: Ver historial de boletos apartados- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

- ✅ **Clean Architecture**: Código organizado y mantenible

For help getting started with Flutter development, view the

## 📁 Estructura del Proyecto[online documentation](https://docs.flutter.dev/), which offers tutorials,

samples, guidance on mobile development, and a full API reference.

```
lib/
├── core/                     # Configuración global
│   ├── constants/           # Constantes de la app
│   ├── theme/              # Tema y colores
│   ├── utils/              # Utilidades y helpers
│   └── router/             # Configuración de navegación
├── data/                    # Capa de datos
│   ├── models/             # Modelos de datos
│   └── repositories/       # Repositorios para acceso a datos
├── presentation/            # Capa de presentación
│   ├── screens/            # Pantallas de la app
│   ├── widgets/            # Widgets reutilizables
│   └── providers/          # Providers de Riverpod
└── services/               # Servicios externos
    ├── supabase_client.dart
    ├── chat_service.dart
    └── notification_service.dart
```

## 🛠️ Tecnologías

- **Flutter**: Framework multiplataforma
- **Supabase**: Backend as a Service (base de datos, auth, realtime, storage)
- **Riverpod**: State management
- **GoRouter**: Navegación
- **Firebase Messaging**: Notificaciones push
- **Clean Architecture**: Patrón de arquitectura

## 📦 Instalación

### 1. Prerrequisitos

- Flutter SDK (>=3.0.0)
- Cuenta de Supabase
- Cuenta de Firebase (para notificaciones)

### 2. Instalar dependencias

```bash
cd rifaswa_cliente
flutter pub get
```

### 3. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Ejecuta el script `supabase_schema.sql` en el SQL Editor de Supabase
3. Copia tu URL y ANON KEY de Supabase
4. Edita `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'TU_SUPABASE_URL';
static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
```

### 4. Configurar Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Agrega tu app Android/iOS
3. Descarga `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
4. Colócalos en:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 5. Habilitar Supabase Realtime

En el dashboard de Supabase:
1. Ve a Database → Replication
2. Habilita realtime para las tablas:
   - `rifas`
   - `boletos`
   - `mensajes`
   - `conversaciones`

## 🏃‍♂️ Ejecutar

```bash
# Android
flutter run

# iOS (requiere Mac)
flutter run

# Web
flutter run -d chrome
```

## 📱 Pantallas

### HomeScreen
- Lista de rifas activas en carrusel
- Grid de todas las rifas
- Badges de notificaciones

### RifaDetailScreen
- Detalles de la rifa (premio, precio, fecha)
- Botón para ver grid de números

### GridNumerosScreen
- Grid 10x10 de números (1-100)
- Colores por estado:
  - **Gris**: Disponible
  - **Amarillo**: Apartado
  - **Verde**: Vendido
  - **Rojo**: Ganador
- Modal para apartar con nombre y teléfono

### ChatScreen
- Burbujas de mensajes (cliente, admin, AI)
- Envío de imágenes
- Indicador de leído
- Actualización en tiempo real

### MisBoletosScreen
- Lista de boletos apartados/vendidos
- Botón para abrir chat por boleto
- Estado visual de cada boleto

### NotificacionesScreen
- Lista de notificaciones push
- Marcar como leída
- Eliminar notificaciones

## 🔐 Autenticación

Por defecto, la app permite login anónimo para pruebas rápidas.

Para implementar autenticación completa:
1. Habilita el método de autenticación en Supabase (Email, Google, etc.)
2. Crea un `LoginScreen`
3. Usa `SupabaseClientService.signIn()` o `signUp()`

## 🔄 Realtime

La app usa Supabase Realtime para:
- Actualizar boletos cuando otro usuario los aparta
- Recibir mensajes del admin en tiempo real
- Sincronizar el estado de las rifas

## 🔔 Notificaciones Push

Las notificaciones se envían desde la app admin usando Firebase Cloud Messaging.

El servicio `NotificationService` maneja:
- Solicitud de permisos
- Recepción de notificaciones en foreground/background
- Almacenamiento local de notificaciones
- Navegación al tocar una notificación

## 🎨 Personalización

### Colores

Edita `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6C63FF);
static const Color secondaryColor = Color(0xFF03DAC6);
```

### Estados de Boletos

Modifica los colores de estados en `AppTheme`:

```dart
static const Color disponibleColor = Colors.grey;
static const Color apartadoColor = Colors.amber;
static const Color vendidoColor = Colors.green;
static const Color ganadorColor = Colors.red;
```

## 📦 Build para Producción

### Android APK
```bash
flutter build apk --release
```

### Android AAB (Play Store)
```bash
flutter build appbundle --release
```

### iOS (requiere Mac con Xcode)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🐛 Troubleshooting

### Error: Supabase not initialized
- Verifica que las credenciales en `app_constants.dart` sean correctas
- Asegúrate de que `SupabaseClientService.initialize()` se ejecute antes de `runApp()`

### Notificaciones no llegan
- Verifica permisos en el dispositivo
- Comprueba que Firebase esté configurado correctamente
- Revisa los logs de Firebase Console

### Realtime no funciona
- Verifica que Realtime esté habilitado para las tablas en Supabase
- Comprueba las políticas RLS
- Asegúrate de que el usuario tenga permisos de lectura

### Error al apartar boleto
- Verifica que el usuario esté autenticado
- Comprueba que el número no esté ya apartado
- Revisa las políticas RLS de la tabla `boletos`

## 📄 Estructura de Base de Datos

El archivo `supabase_schema.sql` contiene:
- Tablas: rifas, boletos, conversaciones, mensajes, notificaciones
- Índices para mejor performance
- Triggers para updated_at
- Políticas RLS (Row Level Security)
- Bucket de Storage para imágenes
- Funciones útiles (estadísticas de rifas)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

MIT License

## 👥 Autor

Rifas W&A Team

## 🔗 Enlaces Útiles

- [Documentación de Flutter](https://docs.flutter.dev)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Messaging](https://firebase.google.com/docs/cloud-messaging)
- [GoRouter](https://pub.dev/packages/go_router)
