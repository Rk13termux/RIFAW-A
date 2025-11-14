# Configuración de Firebase

Esta guía te ayudará a configurar Firebase para las notificaciones push.

## Paso 1: Crear proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Haz clic en "Agregar proyecto"
3. Nombre del proyecto: "Rifas WA" (o el que prefieras)
4. Acepta los términos y crea el proyecto

## Paso 2: Agregar apps al proyecto

### Para Android:

1. En la consola de Firebase, haz clic en el ícono de Android
2. Package name: `com.example.rifaswa_cliente` (puedes cambiarlo en `android/app/build.gradle.kts`)
3. Descarga el archivo `google-services.json`
4. Coloca `google-services.json` en: `android/app/`

5. Agrega el plugin de Google Services en `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

6. En `android/app/build.gradle.kts`, agrega al final:

```kotlin
apply plugin: 'com.google.gms.google-services'
```

### Para iOS:

1. En la consola de Firebase, haz clic en el ícono de iOS
2. Bundle ID: `com.example.rifaswaCliente` (puedes cambiarlo en Xcode)
3. Descarga el archivo `GoogleService-Info.plist`
4. Abre el proyecto iOS en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
5. Arrastra `GoogleService-Info.plist` al proyecto Runner (asegúrate de que "Copy items if needed" esté marcado)

## Paso 3: Habilitar Cloud Messaging

1. En Firebase Console, ve a **Build** → **Cloud Messaging**
2. Ve a la pestaña **Cloud Messaging API (Legacy)**
3. Habilita la API
4. Copia la **Server Key** (la necesitarás para enviar notificaciones desde el backend)

## Paso 4: Configurar APNs (Solo iOS)

1. Necesitas una cuenta de Apple Developer
2. Crea un **APNs Key** en tu cuenta de desarrollador
3. Sube el archivo .p8 a Firebase Console en **Project Settings** → **Cloud Messaging** → **APNs Certificates**

## Paso 5: Probar notificaciones

### Desde Firebase Console:

1. Ve a **Engage** → **Cloud Messaging**
2. Haz clic en "Send your first message"
3. Título y mensaje de prueba
4. Selecciona la app
5. Envía la notificación

### Desde código (Admin):

```typescript
// Función para enviar notificación individual
async function enviarNotificacion(token: string, titulo: string, mensaje: string) {
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=TU_SERVER_KEY_AQUI'
    },
    body: JSON.stringify({
      to: token,
      notification: {
        title: titulo,
        body: mensaje
      },
      data: {
        tipo: 'rifa',
        rifa_id: 'uuid-de-la-rifa'
      }
    })
  })
  
  return await response.json()
}

// Función para enviar notificación a múltiples usuarios
async function enviarNotificacionMasiva(tokens: string[], titulo: string, mensaje: string) {
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=TU_SERVER_KEY_AQUI'
    },
    body: JSON.stringify({
      registration_ids: tokens,
      notification: {
        title: titulo,
        body: mensaje
      }
    })
  })
  
  return await response.json()
}
```

## Paso 6: Guardar tokens FCM

Para enviar notificaciones, necesitas guardar los tokens FCM de los usuarios.

### Opción 1: Tabla en Supabase

```sql
create table fcm_tokens (
  id uuid primary key default uuid_generate_v4(),
  usuario_id uuid references auth.users not null,
  token text not null,
  plataforma text, -- 'android', 'ios', 'web'
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(usuario_id, token)
);
```

### Opción 2: Perfil de usuario

Agrega el token al perfil del usuario en `auth.users.raw_user_meta_data`.

## Paso 7: Permisos en Android

El archivo `android/app/src/main/AndroidManifest.xml` ya debería tener:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## Paso 8: Permisos en iOS

El sistema solicitará permisos automáticamente cuando llames a:

```dart
await NotificationService().initialize();
```

## Troubleshooting

### Android: Notificaciones no llegan

1. Verifica que `google-services.json` esté en `android/app/`
2. Comprueba que el package name coincida
3. Verifica que el plugin de Google Services esté aplicado
4. Revisa los logs: `flutter run` y busca errores de Firebase

### iOS: Notificaciones no llegan

1. Verifica que `GoogleService-Info.plist` esté en el proyecto de Xcode
2. Comprueba el Bundle ID
3. Asegúrate de haber configurado APNs
4. Verifica las capabilities en Xcode:
   - Push Notifications
   - Background Modes → Remote notifications

### Token no se genera

1. Verifica que Firebase esté inicializado correctamente
2. Comprueba los permisos
3. Revisa los logs de la app

### Error: "Default FirebaseApp is not initialized"

Asegúrate de que en `main.dart`:

```dart
await Firebase.initializeApp();
```

se ejecute ANTES de `runApp()`.

## Tipos de notificaciones

### Notificación simple
Solo muestra título y mensaje

### Notificación con datos
Incluye datos personalizados que puedes usar para navegar:

```dart
data: {
  tipo: 'rifa',
  rifa_id: 'uuid',
  accion: 'abrir'
}
```

### Notificación programada
Enviar en una fecha/hora específica

### Notificación silenciosa
Solo datos, sin mostrar notificación visible

## Recursos

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)
