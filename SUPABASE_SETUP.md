# Configuración de Supabase

Este archivo contiene instrucciones para configurar Supabase correctamente.

## Paso 1: Crear proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Guarda:
   - Project URL
   - Anon/Public Key

## Paso 2: Ejecutar el schema SQL

1. En tu proyecto de Supabase, ve a **SQL Editor**
2. Abre el archivo `supabase_schema.sql` de este proyecto
3. Copia todo el contenido
4. Pégalo en el SQL Editor de Supabase
5. Haz clic en **Run** para ejecutar el script

Esto creará:
- ✅ Tablas: rifas, boletos, conversaciones, mensajes, notificaciones
- ✅ Índices para mejor rendimiento
- ✅ Triggers para updated_at
- ✅ Políticas RLS (Row Level Security)
- ✅ Bucket de Storage para imágenes
- ✅ Funciones útiles

## Paso 3: Habilitar Realtime

1. Ve a **Database** → **Replication**
2. Habilita realtime para estas tablas:
   - ☑️ rifas
   - ☑️ boletos
   - ☑️ mensajes
   - ☑️ conversaciones

## Paso 4: Configurar Authentication

1. Ve a **Authentication** → **Providers**
2. Habilita los métodos que necesites:
   - Email (recomendado para pruebas)
   - Google
   - Apple
   - etc.

3. Para pruebas rápidas, puedes usar **Anonymous Sign-ins**

## Paso 5: Configurar Storage

El bucket 'rifas' ya se crea con el script SQL.

Verifica que esté configurado como público para que las imágenes sean accesibles.

## Paso 6: Actualizar credenciales en la app

Edita el archivo `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
static const String supabaseAnonKey = 'tu-anon-key-aqui';
```

## Paso 7: Crear usuario admin de prueba

1. Ve a **Authentication** → **Users**
2. Crea un usuario (será el admin)
3. Copia su UUID
4. En SQL Editor, ejecuta:

```sql
insert into rifas (admin_id, titulo, premio, descripcion, precio_boleto, total_boletos, estado)
values (
  'UUID_DEL_ADMIN_AQUI',
  'Rifa iPhone 15 Pro',
  'iPhone 15 Pro Max 256GB',
  'Participa y gana el último iPhone 15 Pro Max',
  50.00,
  100,
  'activa'
);
```

## Troubleshooting

### Error: "relation does not exist"
- Asegúrate de haber ejecutado completamente el script SQL
- Verifica que no haya errores en el SQL Editor

### Error: "permission denied"
- Verifica las políticas RLS
- Asegúrate de que el usuario esté autenticado

### Realtime no funciona
- Verifica que Realtime esté habilitado en Database → Replication
- Comprueba que las políticas RLS permitan SELECT

### Storage no funciona
- Verifica que el bucket 'rifas' exista
- Comprueba que sea público
- Verifica las políticas de storage

## Recursos adicionales

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Realtime](https://supabase.com/docs/guides/realtime)
