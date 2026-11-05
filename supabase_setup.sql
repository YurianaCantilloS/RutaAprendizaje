-- ============================================================
--  RUTA PROFESIONAL · Configuración inicial de Supabase
--  Ejecutar UNA sola vez en: Supabase → SQL Editor → New query
--  Es seguro volver a ejecutarlo (no borra tus datos).
-- ============================================================

-- 1) Tabla donde se guarda TODO el estado:
--    perfil, módulos, temas, progreso (checks), enlaces y certificados.
create table if not exists public.ruta_state (
  id         text primary key,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- 2) Seguridad a nivel de fila (RLS)
alter table public.ruta_state enable row level security;

drop policy if exists "ruta select" on public.ruta_state;
drop policy if exists "ruta insert" on public.ruta_state;
drop policy if exists "ruta update" on public.ruta_state;

create policy "ruta select" on public.ruta_state
  for select to anon, authenticated using (true);

create policy "ruta insert" on public.ruta_state
  for insert to anon, authenticated with check (true);

create policy "ruta update" on public.ruta_state
  for update to anon, authenticated using (true) with check (true);

-- Permisos para la clave "anon / public"
grant select, insert, update on public.ruta_state to anon, authenticated;

-- 3) Bucket público para fotos de perfil y certificados
insert into storage.buckets (id, name, public)
values ('ruta-files', 'ruta-files', true)
on conflict (id) do update set public = true;

-- 4) Políticas del bucket (subir, ver, borrar archivos)
drop policy if exists "ruta files select" on storage.objects;
drop policy if exists "ruta files insert" on storage.objects;
drop policy if exists "ruta files update" on storage.objects;
drop policy if exists "ruta files delete" on storage.objects;

create policy "ruta files select" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'ruta-files');

create policy "ruta files insert" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'ruta-files');

create policy "ruta files update" on storage.objects
  for update to anon, authenticated
  using (bucket_id = 'ruta-files')
  with check (bucket_id = 'ruta-files');

create policy "ruta files delete" on storage.objects
  for delete to anon, authenticated
  using (bucket_id = 'ruta-files');

-- ============================================================
--  Listo. Verifica en Table Editor que exista "ruta_state"
--  y en Storage que exista el bucket "ruta-files".
-- ============================================================
