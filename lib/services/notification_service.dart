import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_constants.dart';
import '../data/models/notificacion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final List<NotificacionModel> _notifications = [];
  List<NotificacionModel> get notifications => List.unmodifiable(_notifications);

  Future<void> initialize() async {
    // Solicitar permisos
    await _requestPermissions();

    // Configurar notificaciones locales
    await _setupLocalNotifications();

    // Configurar Firebase Messaging
    await _setupFirebaseMessaging();

    // Cargar notificaciones guardadas
    await _loadNotifications();
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Permission granted: ${settings.authorizationStatus}');
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _setupFirebaseMessaging() async {
    // Handler para mensajes en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Obtener token FCM
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Escuchar cambios de token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // Aquí podrías enviar el token al backend
    });

    // Mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensajes cuando la app se abre desde notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app se abrió desde una notificación
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.messageId}');
    
    final notification = NotificacionModel(
      id: message.messageId ?? DateTime.now().toString(),
      titulo: message.notification?.title ?? 'Nueva notificación',
      mensaje: message.notification?.body ?? '',
      tipo: message.data['tipo'],
      rifaId: message.data['rifa_id'],
      fecha: DateTime.now(),
      leida: false,
    );

    _addNotification(notification);
    _showLocalNotification(notification);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    
    final notification = NotificacionModel(
      id: message.messageId ?? DateTime.now().toString(),
      titulo: message.notification?.title ?? 'Nueva notificación',
      mensaje: message.notification?.body ?? '',
      tipo: message.data['tipo'],
      rifaId: message.data['rifa_id'],
      fecha: DateTime.now(),
      leida: true,
    );

    _addNotification(notification);
    // Navegar a la pantalla correspondiente según el tipo
  }

  Future<void> _showLocalNotification(NotificacionModel notification) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.fecha.millisecondsSinceEpoch ~/ 1000,
      notification.titulo,
      notification.mensaje,
      details,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navegar a la pantalla correspondiente
  }

  void _addNotification(NotificacionModel notification) {
    _notifications.insert(0, notification);
    _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications.map((n) => n.toJson()).toList();
    await prefs.setString('notifications', jsonEncode(notificationsJson));
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsString = prefs.getString('notifications');
    
    if (notificationsString != null) {
      final notificationsJson = jsonDecode(notificationsString) as List;
      _notifications.clear();
      _notifications.addAll(
        notificationsJson.map((json) => NotificacionModel.fromJson(json)),
      );
    }
  }

  Future<void> marcarComoLeida(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(leida: true);
      await _saveNotifications();
    }
  }

  Future<void> eliminarNotificacion(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  Future<void> limpiarTodas() async {
    _notifications.clear();
    await _saveNotifications();
  }

  int get unreadCount => _notifications.where((n) => !n.leida).length;
}
