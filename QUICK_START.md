# 🚀 Quick Start - Rifas W&A Cliente

## ⚡ Inicio Rápido (5 minutos)

### 1. Instalar dependencias
```bash
cd rifaswa_cliente
flutter pub get
```

### 2. Configurar Supabase (OBLIGATORIO)

Edita `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'TU_SUPABASE_URL_AQUI';
static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY_AQUI';
```

**¿Cómo obtener las credenciales?**
1. Ve a [https://supabase.com](https://supabase.com)
2. Crea un proyecto (gratis)
3. Ve a Settings → API
4. Copia:
   - Project URL → `supabaseUrl`
   - anon/public key → `supabaseAnonKey`

### 3. Crear base de datos

1. En Supabase, ve a **SQL Editor**
2. Copia todo el contenido de `supabase_schema.sql`
3. Pégalo y ejecuta (**Run**)
4. Verifica que se crearon las tablas en **Database → Tables**

### 4. Habilitar Realtime

1. En Supabase, ve a **Database → Replication**
2. Habilita realtime para:
   - ✅ rifas
   - ✅ boletos
   - ✅ mensajes
   - ✅ conversaciones

### 5. Ejecutar la app
```bash
flutter run
```

## 🎯 Testing sin Firebase (Opcional)

Si no quieres configurar Firebase ahora, comenta estas líneas en `lib/main.dart`:

```dart
// await Firebase.initializeApp();
// await NotificationService().initialize();
```

La app funcionará sin notificaciones push.

## 📊 Crear datos de prueba

### Opción 1: SQL Manual

En Supabase SQL Editor:

```sql
-- Primero, crea un usuario en Authentication → Users
-- Luego, usa su UUID aquí:

insert into rifas (admin_id, titulo, premio, descripcion, precio_boleto, total_boletos, estado, imagen_url)
values (
  'UUID_DE_TU_USUARIO',
  'Rifa iPhone 15 Pro',
  'iPhone 15 Pro Max 256GB',
  'Participa y gana el último iPhone 15 Pro Max con 256GB de almacenamiento',
  50.00,
  100,
  'activa',
  'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800'
);

insert into rifas (admin_id, titulo, premio, descripcion, precio_boleto, total_boletos, estado, imagen_url)
values (
  'UUID_DE_TU_USUARIO',
  'Rifa PlayStation 5',
  'PlayStation 5 + 2 controles',
  'Incluye consola PS5, 2 controles DualSense y 3 juegos',
  30.00,
  100,
  'activa',
  'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=800'
);

insert into rifas (admin_id, titulo, premio, descripcion, precio_boleto, total_boletos, estado, imagen_url)
values (
  'UUID_DE_TU_USUARIO',
  'Rifa MacBook Air',
  'MacBook Air M2 2024',
  'Laptop Apple MacBook Air con chip M2, 16GB RAM, 512GB SSD',
  75.00,
  100,
  'activa',
  'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800'
);
```

### Opción 2: Desde la App (Requiere App Admin)

Espera a que se cree la app admin y crea rifas desde ahí.

## 🔑 Autenticación de Prueba

### Login Anónimo (Default)

La app usa login anónimo por defecto. No necesitas hacer nada.

### Login con Email (Opcional)

1. En Supabase, ve a **Authentication → Providers**
2. Habilita **Email**
3. En **Authentication → Users**, crea un usuario de prueba:
   - Email: test@ejemplo.com
   - Password: test123456

4. Modifica `lib/services/supabase_client.dart` para usar:
```dart
await signIn('test@ejemplo.com', 'test123456');
```

## 📱 Probar Funcionalidades

### 1. Ver Rifas
- Abre la app
- Deberías ver las rifas creadas
- Prueba el carrusel y el grid

### 2. Apartar Boleto
- Toca una rifa
- Toca "Ver Números"
- Selecciona un número gris (disponible)
- Llena el formulario
- Toca "Apartar Boleto"

### 3. Ver Mis Boletos
- Toca el ícono de boletos en el AppBar
- Verifica que aparezca el boleto apartado

### 4. Realtime
- Abre la app en dos dispositivos/emuladores
- Aparta un boleto en uno
- Observa la actualización automática en el otro

### 5. Chat (Requiere conversación)
- Desde "Mis Boletos", toca el ícono de chat
- Envía un mensaje
- Responde desde la app admin (cuando esté lista)

## 🐛 Troubleshooting Rápido

### Error: "Invalid API Key"
→ Verifica las credenciales en `app_constants.dart`

### Error: "relation does not exist"
→ Ejecuta `supabase_schema.sql` en Supabase SQL Editor

### No se ven rifas
→ Verifica que creaste rifas con estado 'activa' o 'vendiendo'
→ Verifica que el admin_id coincida con tu usuario

### Error de compilación
→ Ejecuta `flutter clean && flutter pub get`

### Realtime no funciona
→ Verifica que habilitaste Realtime en las tablas
→ Revisa las políticas RLS

## 📚 Documentación Completa

- **README.md** - Documentación general
- **SUPABASE_SETUP.md** - Configuración detallada de Supabase
- **FIREBASE_SETUP.md** - Configuración de notificaciones
- **DEPLOYMENT.md** - Guía de publicación
- **CHECKLIST.md** - Lista de verificación completa
- **PROJECT_SUMMARY.md** - Resumen del proyecto

## 🎨 Personalización Rápida

### Cambiar colores

`lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6C63FF); // Tu color aquí
```

### Cambiar nombre de la app

`pubspec.yaml`:
```yaml
name: tu_nombre_app
```

## ⚠️ Importante

### Antes de producción:
1. ✅ Configura Firebase para notificaciones
2. ✅ Cambia las credenciales a producción
3. ✅ Revisa todas las políticas RLS
4. ✅ Prueba en dispositivos reales
5. ✅ Crea política de privacidad

## 🚀 Next Steps

1. ✅ Configura Firebase (FIREBASE_SETUP.md)
2. ✅ Crea la app admin (rifaswa_admin)
3. ✅ Prueba el flujo completo
4. ✅ Personaliza el diseño
5. ✅ Deploy a producción (DEPLOYMENT.md)

---

## 💡 Tips

- Usa el Hot Reload de Flutter (presiona 'r' en la consola)
- Revisa los logs para debugging
- Usa Supabase Dashboard para ver la BD en tiempo real
- Prueba en modo debug primero

## 🆘 ¿Necesitas ayuda?

1. Revisa la documentación completa
2. Verifica los logs de error
3. Consulta la consola de Supabase
4. Revisa las políticas RLS

---

**¡Listo para empezar! 🎉**

Tiempo estimado de setup: **10-15 minutos**
