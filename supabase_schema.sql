-- ===================================================================
-- RIFAS W&A - SCHEMA DE BASE DE DATOS SUPABASE
-- Compartida entre app admin y app cliente
-- ===================================================================

-- Habilitar la extensión UUID
create extension if not exists "uuid-ossp";

-- ===================================================================
-- TABLAS
-- ===================================================================

-- Tabla de rifas
create table if not exists rifas (
  id uuid primary key default uuid_generate_v4(),
  admin_id uuid references auth.users not null,
  titulo text not null,
  premio text not null,
  descripcion text,
  precio_boleto numeric not null check (precio_boleto > 0),
  total_boletos int not null check (total_boletos > 0),
  fecha_sorteo timestamp with time zone,
  imagen_url text,
  estado text check (estado in ('activa', 'vendiendo', 'sorteada', 'finalizada')) default 'activa',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Tabla de boletos
create table if not exists boletos (
  id uuid primary key default uuid_generate_v4(),
  rifa_id uuid references rifas(id) on delete cascade not null,
  numero int not null check (numero > 0),
  cliente_id uuid references auth.users,
  nombre_cliente text,
  telefono text,
  fecha_compra timestamp with time zone default now(),
  estado text check (estado in ('disponible', 'apartado', 'vendido', 'ganador')) default 'disponible',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(rifa_id, numero)
);

-- Tabla de conversaciones (chat)
create table if not exists conversaciones (
  id uuid primary key default uuid_generate_v4(),
  rifa_id uuid references rifas(id) on delete cascade not null,
  cliente_id uuid references auth.users not null,
  admin_id uuid references auth.users not null,
  ultimo_mensaje text,
  visto_cliente boolean default false,
  visto_admin boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(rifa_id, cliente_id)
);

-- Tabla de mensajes
create table if not exists mensajes (
  id uuid primary key default uuid_generate_v4(),
  conversacion_id uuid references conversaciones(id) on delete cascade not null,
  emisor text check (emisor in ('cliente', 'admin', 'ai')) not null,
  texto text,
  imagen_url text,
  fecha timestamp with time zone default now(),
  leido boolean default false,
  created_at timestamp with time zone default now(),
  constraint check_mensaje_content check (texto is not null or imagen_url is not null)
);

-- Tabla de notificaciones push (opcional, para tracking)
create table if not exists notificaciones (
  id uuid primary key default uuid_generate_v4(),
  usuario_id uuid references auth.users not null,
  titulo text not null,
  mensaje text not null,
  tipo text, -- 'rifa', 'boleto', 'chat', 'sorteo'
  rifa_id uuid references rifas(id) on delete cascade,
  leida boolean default false,
  enviada boolean default false,
  fecha timestamp with time zone default now(),
  created_at timestamp with time zone default now()
);

-- ===================================================================
-- ÍNDICES PARA MEJOR PERFORMANCE
-- ===================================================================

create index if not exists idx_rifas_estado on rifas(estado);
create index if not exists idx_rifas_admin on rifas(admin_id);
create index if not exists idx_boletos_rifa on boletos(rifa_id);
create index if not exists idx_boletos_cliente on boletos(cliente_id);
create index if not exists idx_boletos_estado on boletos(estado);
create index if not exists idx_conversaciones_cliente on conversaciones(cliente_id);
create index if not exists idx_conversaciones_admin on conversaciones(admin_id);
create index if not exists idx_mensajes_conversacion on mensajes(conversacion_id);
create index if not exists idx_mensajes_fecha on mensajes(fecha);
create index if not exists idx_notificaciones_usuario on notificaciones(usuario_id);

-- ===================================================================
-- TRIGGERS PARA UPDATED_AT
-- ===================================================================

create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger update_rifas_updated_at before update on rifas
  for each row execute function update_updated_at_column();

create trigger update_boletos_updated_at before update on boletos
  for each row execute function update_updated_at_column();

create trigger update_conversaciones_updated_at before update on conversaciones
  for each row execute function update_updated_at_column();

-- ===================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ===================================================================

-- Habilitar RLS en todas las tablas
alter table rifas enable row level security;
alter table boletos enable row level security;
alter table conversaciones enable row level security;
alter table mensajes enable row level security;
alter table notificaciones enable row level security;

-- ===================================================================
-- POLÍTICAS PARA RIFAS
-- ===================================================================

-- Los clientes pueden ver rifas activas o en venta
create policy "cliente_puede_ver_rifas_activas"
  on rifas for select
  using (estado in ('activa', 'vendiendo'));

-- Los admins pueden hacer todo en sus rifas
create policy "admin_puede_gestionar_sus_rifas"
  on rifas for all
  using (auth.uid() = admin_id);

-- ===================================================================
-- POLÍTICAS PARA BOLETOS
-- ===================================================================

-- Los clientes pueden ver boletos de rifas activas
create policy "cliente_puede_ver_boletos_rifas_activas"
  on boletos for select
  using (
    exists (
      select 1 from rifas r 
      where r.id = boletos.rifa_id 
      and r.estado in ('activa', 'vendiendo', 'sorteada')
    )
  );

-- Los clientes pueden apartar boletos (insertar) si están autenticados
create policy "cliente_puede_apartar_boleto"
  on boletos for insert
  with check (
    auth.uid() = cliente_id
    and estado = 'apartado'
    and exists (
      select 1 from rifas r 
      where r.id = boletos.rifa_id 
      and r.estado in ('activa', 'vendiendo')
    )
  );

-- Los clientes pueden actualizar sus propios boletos
create policy "cliente_puede_actualizar_sus_boletos"
  on boletos for update
  using (auth.uid() = cliente_id);

-- Los admins pueden hacer todo en boletos de sus rifas
create policy "admin_puede_gestionar_boletos_sus_rifas"
  on boletos for all
  using (
    exists (
      select 1 from rifas r 
      where r.id = boletos.rifa_id 
      and r.admin_id = auth.uid()
    )
  );

-- ===================================================================
-- POLÍTICAS PARA CONVERSACIONES
-- ===================================================================

-- Los clientes pueden ver sus conversaciones
create policy "cliente_puede_ver_sus_conversaciones"
  on conversaciones for select
  using (auth.uid() = cliente_id);

-- Los clientes pueden crear conversaciones
create policy "cliente_puede_crear_conversacion"
  on conversaciones for insert
  with check (auth.uid() = cliente_id);

-- Los clientes pueden actualizar sus conversaciones (marcar como visto)
create policy "cliente_puede_actualizar_sus_conversaciones"
  on conversaciones for update
  using (auth.uid() = cliente_id);

-- Los admins pueden ver conversaciones de sus rifas
create policy "admin_puede_ver_conversaciones_sus_rifas"
  on conversaciones for select
  using (auth.uid() = admin_id);

-- Los admins pueden actualizar conversaciones de sus rifas
create policy "admin_puede_actualizar_conversaciones_sus_rifas"
  on conversaciones for update
  using (auth.uid() = admin_id);

-- ===================================================================
-- POLÍTICAS PARA MENSAJES
-- ===================================================================

-- Los clientes pueden ver mensajes de sus conversaciones
create policy "cliente_puede_ver_mensajes_sus_conversaciones"
  on mensajes for select
  using (
    exists (
      select 1 from conversaciones c 
      where c.id = mensajes.conversacion_id 
      and c.cliente_id = auth.uid()
    )
  );

-- Los clientes pueden enviar mensajes en sus conversaciones
create policy "cliente_puede_enviar_mensajes"
  on mensajes for insert
  with check (
    emisor = 'cliente'
    and exists (
      select 1 from conversaciones c 
      where c.id = mensajes.conversacion_id 
      and c.cliente_id = auth.uid()
    )
  );

-- Los clientes pueden actualizar mensajes (marcar como leído)
create policy "cliente_puede_marcar_mensajes_leidos"
  on mensajes for update
  using (
    exists (
      select 1 from conversaciones c 
      where c.id = mensajes.conversacion_id 
      and c.cliente_id = auth.uid()
    )
  );

-- Los admins pueden gestionar mensajes de sus conversaciones
create policy "admin_puede_gestionar_mensajes_sus_conversaciones"
  on mensajes for all
  using (
    exists (
      select 1 from conversaciones c 
      where c.id = mensajes.conversacion_id 
      and c.admin_id = auth.uid()
    )
  );

-- ===================================================================
-- POLÍTICAS PARA NOTIFICACIONES
-- ===================================================================

-- Los usuarios pueden ver sus notificaciones
create policy "usuario_puede_ver_sus_notificaciones"
  on notificaciones for select
  using (auth.uid() = usuario_id);

-- Los usuarios pueden actualizar sus notificaciones (marcar como leída)
create policy "usuario_puede_actualizar_sus_notificaciones"
  on notificaciones for update
  using (auth.uid() = usuario_id);

-- Los usuarios pueden eliminar sus notificaciones
create policy "usuario_puede_eliminar_sus_notificaciones"
  on notificaciones for delete
  using (auth.uid() = usuario_id);

-- Los admins pueden crear notificaciones
create policy "admin_puede_crear_notificaciones"
  on notificaciones for insert
  with check (true); -- TODO: Restringir solo a admins

-- ===================================================================
-- FUNCIONES ÚTILES
-- ===================================================================

-- Función para obtener estadísticas de una rifa
create or replace function get_rifa_stats(rifa_uuid uuid)
returns json as $$
declare
  stats json;
begin
  select json_build_object(
    'total_boletos', r.total_boletos,
    'boletos_disponibles', count(*) filter (where b.estado = 'disponible'),
    'boletos_apartados', count(*) filter (where b.estado = 'apartado'),
    'boletos_vendidos', count(*) filter (where b.estado = 'vendido'),
    'total_recaudado', r.precio_boleto * count(*) filter (where b.estado in ('apartado', 'vendido')),
    'porcentaje_vendido', (count(*) filter (where b.estado in ('apartado', 'vendido'))::float / r.total_boletos * 100)::numeric(5,2)
  ) into stats
  from rifas r
  left join boletos b on b.rifa_id = r.id
  where r.id = rifa_uuid
  group by r.id, r.total_boletos, r.precio_boleto;
  
  return stats;
end;
$$ language plpgsql security definer;

-- ===================================================================
-- STORAGE BUCKET PARA IMÁGENES
-- ===================================================================

-- Crear bucket para imágenes de rifas y chat
insert into storage.buckets (id, name, public)
values ('rifas', 'rifas', true)
on conflict (id) do nothing;

-- Política para permitir subir imágenes (usuarios autenticados)
create policy "usuarios_autenticados_pueden_subir"
  on storage.objects for insert
  with check (
    bucket_id = 'rifas'
    and auth.role() = 'authenticated'
  );

-- Política para ver imágenes (público)
create policy "imagenes_publicas"
  on storage.objects for select
  using (bucket_id = 'rifas');

-- Política para eliminar imágenes (solo el dueño)
create policy "usuarios_pueden_eliminar_sus_imagenes"
  on storage.objects for delete
  using (
    bucket_id = 'rifas'
    and auth.uid() = owner
  );

-- ===================================================================
-- DATOS DE EJEMPLO (OPCIONAL - COMENTAR EN PRODUCCIÓN)
-- ===================================================================

-- Descomentar para crear datos de prueba
/*
-- Crear un usuario admin de ejemplo (necesitas el UUID real de tu usuario)
-- insert into rifas (admin_id, titulo, premio, descripcion, precio_boleto, total_boletos, estado)
-- values (
--   'TU_UUID_ADMIN_AQUI',
--   'Rifa iPhone 15 Pro',
--   'iPhone 15 Pro Max 256GB',
--   'Participa y gana el último iPhone 15 Pro Max',
--   50.00,
--   100,
--   'activa'
-- );
*/
