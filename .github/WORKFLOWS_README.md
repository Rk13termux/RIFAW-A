# 🚀 GitHub Actions CI/CD

Este proyecto incluye workflows automatizados para compilar la aplicación en todas las plataformas.

## 📋 Workflows Disponibles

### 1. **Build & Release** (`build.yml`)
Se ejecuta automáticamente en cada `push` o `pull request` a la rama `main`.

**Plataformas compiladas:**
- ✅ Android (APK split por ABI: ARM64, ARMv7, x86_64)
- ✅ iOS (IPA sin firmar)
- ✅ Web (archivos estáticos)
- ✅ Linux (x64 tarball)
- ✅ Windows (x64 ZIP)
- ✅ macOS (app ZIP)

**Artifacts generados:** Los archivos compilados están disponibles durante 30 días en la sección "Actions" → "Artifacts".

### 2. **Release Build** (`release.yml`)
Se ejecuta cuando se crea un tag de versión (`v*`) o manualmente desde GitHub Actions.

**Características:**
- Crea una release automática en GitHub
- Compila todas las plataformas
- Adjunta los binarios a la release
- Incluye notas de versión formateadas

## 🎯 Cómo Usar

### Compilación Automática (Push)

Simplemente haz push a la rama `main`:

```bash
git add .
git commit -m "feat: nueva característica"
git push origin main
```

Ve a `Actions` en GitHub para ver el progreso y descargar los artifacts cuando termine.

### Crear una Release

**Opción 1: Con Tag**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Opción 2: Manual desde GitHub**
1. Ve a `Actions` → `Release Build`
2. Click en `Run workflow`
3. Ingresa la versión (ej: `v1.0.0`)
4. Click en `Run workflow`

### Descargar Artifacts

**Desde Actions:**
1. Ve a `Actions` en GitHub
2. Selecciona el workflow completado
3. Scroll hasta `Artifacts`
4. Descarga el que necesites

**Desde Releases:**
1. Ve a `Releases` en GitHub
2. Descarga los archivos adjuntos

## 📦 Artifacts Generados

| Plataforma | Archivo | Descripción |
|-----------|---------|-------------|
| Android | `app-arm64-v8a-release.apk` | APK para ARM64 (dispositivos modernos) |
| Android | `app-armeabi-v7a-release.apk` | APK para ARMv7 (dispositivos antiguos) |
| Android | `app-x86_64-release.apk` | APK para emuladores x86 |
| iOS | `rifaswa-cliente-ios.ipa` | IPA sin firmar (requiere certificado) |
| Web | `rifaswa-cliente-web.zip` | Archivos estáticos para hosting |
| Linux | `rifaswa-cliente-linux-x64.tar.gz` | Bundle para Linux x64 |
| Windows | `rifaswa-cliente-windows-x64.zip` | Ejecutable para Windows |
| macOS | `rifaswa-cliente-macos.zip` | App para macOS |

## ⚙️ Configuración

Los workflows están configurados para usar:
- **Flutter**: 3.35.4 (stable channel)
- **Java**: 17 (Zulu distribution)
- **Actions**: v4 (última versión estable)
- **Cache**: Habilitado para Flutter y Gradle

## 🔧 Personalización

### Cambiar versión de Flutter

Edita en ambos workflows:
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.35.4'  # ← Cambiar aquí
    channel: 'stable'
```

### Agregar firma de Android

1. Agrega los secrets en GitHub:
   - `KEYSTORE_FILE` (base64)
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`

2. Modifica el workflow de Android:
```yaml
- name: Build APK (signed)
  env:
    KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
    KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
  run: |
    echo "${{ secrets.KEYSTORE_FILE }}" | base64 -d > android/app/keystore.jks
    flutter build apk --release --split-per-abi
```

### Agregar firma de iOS

1. Configura los secrets:
   - `IOS_CERTIFICATE`
   - `IOS_PROVISIONING_PROFILE`
   - `CERTIFICATE_PASSWORD`

2. Usa `fastlane` en el workflow de iOS

## 📊 Estado de los Workflows

Puedes ver el estado actual en la sección `Actions` de GitHub o agregar badges al README:

```markdown
![Build Status](https://github.com/Rk13termux/RIFAW-A/actions/workflows/build.yml/badge.svg)
![Release Status](https://github.com/Rk13termux/RIFAW-A/actions/workflows/release.yml/badge.svg)
```

## 🐛 Troubleshooting

### Error: "Flutter command not found"
- Verifica que `subosito/flutter-action@v2` esté correctamente configurado
- Asegúrate de que el cache esté habilitado

### Error: "Unable to find java"
- Verifica la versión de Java en `setup-java@v4`
- Confirma que `java-version: '17'` sea correcta

### Error: "Build failed for platform X"
- Revisa los logs específicos de la plataforma
- Verifica que las dependencias nativas estén instaladas
- Para Linux: confirma que `pkg-config`, `libgtk-3-dev` estén en el workflow

### Artifacts no aparecen
- Verifica que el workflow haya completado exitosamente
- Confirma que `actions/upload-artifact@v4` se ejecutó
- Los artifacts expiran después de 30 días

## 📝 Notas

- **iOS**: Los builds no están firmados. Para distribuir en App Store, necesitas configurar certificados.
- **macOS**: Similar a iOS, requiere firma para notarización.
- **Windows/Linux**: Los builds están listos para distribuir.
- **Web**: Puedes desplegar directamente en Firebase Hosting, Vercel, o Netlify.

## 🚀 Próximos Pasos

1. Configurar firma de Android para Play Store
2. Configurar firma de iOS para App Store
3. Agregar tests automatizados
4. Configurar despliegue automático a Firebase Hosting (Web)
5. Agregar análisis de código con SonarCloud
