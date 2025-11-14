# Guía de Deployment

Esta guía cubre el proceso de despliegue de la app Rifas W&A en diferentes plataformas.

## 📱 Android

### Preparación

1. **Configura el keystore para firma**

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Crea el archivo `android/key.properties`**

```properties
storePassword=tu-password
keyPassword=tu-password
keyAlias=upload
storeFile=/ruta/a/upload-keystore.jks
```

3. **Actualiza `android/app/build.gradle.kts`**

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Build APK

```bash
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (para Play Store)

```bash
flutter build appbundle --release
```

El AAB estará en: `build/app/outputs/bundle/release/app-release.aab`

### Subir a Google Play Console

1. Ve a [Google Play Console](https://play.google.com/console)
2. Crea una app nueva
3. Completa la información de la tienda:
   - Título
   - Descripción corta y larga
   - Screenshots
   - Ícono
   - Banner
4. Ve a "Producción" → "Crear nuevo lanzamiento"
5. Sube el archivo AAB
6. Completa las notas de la versión
7. Revisa y publica

## 🍎 iOS

### Preparación

1. **Requisitos**
   - Mac con Xcode instalado
   - Cuenta de Apple Developer ($99/año)
   - Certificados de desarrollo y distribución

2. **Configura el Bundle ID**

Abre el proyecto en Xcode:
```bash
open ios/Runner.xcworkspace
```

En Xcode:
- Selecciona Runner → General
- Cambia el Bundle Identifier a tu dominio único (ej: `com.tuempresa.rifaswa`)

3. **Configura el equipo de desarrollo**
- En Xcode → Runner → Signing & Capabilities
- Selecciona tu equipo de Apple Developer

### Build

```bash
flutter build ios --release
```

### Archivar para App Store

1. En Xcode, selecciona dispositivo genérico: **Any iOS Device (arm64)**
2. Product → Archive
3. Una vez archivado, se abrirá Organizer
4. Selecciona tu archivo y haz clic en **Distribute App**
5. Selecciona **App Store Connect**
6. Sigue el asistente

### Subir a App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Crea una app nueva
3. Completa la información:
   - Nombre
   - Descripción
   - Screenshots (requiere diferentes tamaños)
   - Categoría
   - Palabras clave
4. Una vez subido el build desde Xcode:
   - Ve a la sección de la app
   - Selecciona el build
   - Envía para revisión

## 🌐 Web

### Build

```bash
flutter build web --release
```

Los archivos estarán en: `build/web/`

### Hosting en Firebase Hosting

1. **Instala Firebase CLI**
```bash
npm install -g firebase-tools
```

2. **Inicia sesión**
```bash
firebase login
```

3. **Inicializa Firebase en tu proyecto**
```bash
firebase init hosting
```

Configuración:
- Public directory: `build/web`
- Configure as single-page app: **Yes**
- Overwrite index.html: **No**

4. **Deploy**
```bash
flutter build web --release
firebase deploy --only hosting
```

### Hosting en Vercel

1. Instala Vercel CLI:
```bash
npm install -g vercel
```

2. Deploy:
```bash
flutter build web --release
cd build/web
vercel
```

### Hosting en Netlify

1. Conecta tu repositorio de GitHub
2. Configuración de build:
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`

## 🔧 Configuración de Producción

### 1. Actualizar constantes

En `lib/core/constants/app_constants.dart`, verifica que uses credenciales de producción:

```dart
static const String supabaseUrl = 'https://tu-proyecto-prod.supabase.co';
static const String supabaseAnonKey = 'tu-prod-anon-key';
```

### 2. Remover código de debug

Busca y remueve:
- `print()` statements
- `debugPrint()`
- Credenciales hardcodeadas
- TODOs

### 3. Optimizaciones

```bash
# Build con tree-shaking
flutter build apk --release --tree-shake-icons

# Build con split per ABI (reduce tamaño)
flutter build apk --split-per-abi
```

### 4. Verificar permisos

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para enviar fotos en el chat</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para enviar imágenes en el chat</string>
```

## 📊 Analytics y Monitoreo

### Firebase Analytics

1. En Firebase Console, habilita Analytics
2. En la app, ya está configurado con `firebase_core`

### Crashlytics

```bash
flutter pub add firebase_crashlytics
```

En `main.dart`:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const ProviderScope(child: RifasWAApp()));
}
```

## 🔐 Seguridad

### 1. Ofuscar código (Android)

En `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Proteger API Keys

Nunca hagas commit de:
- `google-services.json`
- `GoogleService-Info.plist`
- `key.properties`
- Credenciales de Supabase

Usa variables de entorno o archivos `.env` (no versionados).

## ✅ Checklist antes de publicar

- [ ] Código revisado y testeado
- [ ] Credenciales de producción configuradas
- [ ] Permisos verificados
- [ ] Screenshots y assets preparados
- [ ] Versión actualizada en `pubspec.yaml`
- [ ] Notas de la versión escritas
- [ ] Política de privacidad creada
- [ ] Términos y condiciones creados
- [ ] Build firmado correctamente
- [ ] Probado en dispositivos reales
- [ ] Analytics configurado
- [ ] Crashlytics configurado

## 📝 Versionado

Sigue Semantic Versioning:

```yaml
# pubspec.yaml
version: 1.0.0+1
#         ↑     ↑
#      nombre  código
```

- **Nombre**: Major.Minor.Patch (1.0.0)
- **Código**: Número incremental (1, 2, 3, ...)

Incrementa:
- **Major**: Cambios incompatibles
- **Minor**: Nueva funcionalidad compatible
- **Patch**: Correcciones de bugs

## 🚀 CI/CD (Opcional)

### GitHub Actions

Crea `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v1
        with:
          java-version: '12.x'
      - uses: subosito/flutter-action@v1
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v2
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## 🆘 Troubleshooting

### Build falla en Android
- Limpia el cache: `flutter clean`
- Verifica Java version: `java --version`
- Revisa `build.gradle.kts` por errores de sintaxis

### Build falla en iOS
- Actualiza pods: `cd ios && pod install`
- Limpia build: `Product → Clean Build Folder` en Xcode
- Verifica certificados en Xcode

### App crashea al abrir
- Revisa logs: `flutter logs`
- Verifica que Firebase esté inicializado
- Comprueba Supabase credentials

## 📚 Recursos

- [Flutter Deployment](https://docs.flutter.dev/deployment)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
