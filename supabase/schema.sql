create table public.profiles(id uuid primary key references auth.users on delete cascade,
  name text, avatar text, is_admin boolean not null default false, created_at timestamptz default now());
create table public.comments(id bigint generated always as identity primary key, post_slug text not null,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  parent_id bigint references public.comments(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  edited boolean default false, created_at timestamptz default now());
create index on public.comments(post_slug, created_at);
create table public.reports(id bigint generated always as identity primary key,
  comment_id bigint references public.comments(id) on delete cascade,
  user_id uuid default auth.uid(), created_at timestamptz default now(), unique(comment_id,user_id));
create table public.subscribers(id bigint generated always as identity primary key,
  email text unique not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  confirmed boolean default false, token uuid default gen_random_uuid(), created_at timestamptz default now());

create function public.is_admin() returns boolean language sql security definer stable as
$$ select coalesce((select is_admin from public.profiles where id=auth.uid()),false) $$;

-- perfil automático al registrarse
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,name,avatar) values(new.id,
  coalesce(new.raw_user_meta_data->>'full_name',split_part(new.email,'@',1)), new.raw_user_meta_data->>'avatar_url');
return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- límite de tasa: 1 comentario cada 20 s por usuario
create function public.rate_limit() returns trigger language plpgsql as $$
begin if exists(select 1 from public.comments where user_id=new.user_id and created_at>now()-interval '20 seconds')
 then raise exception 'rate limit'; end if; return new; end $$;
create trigger comments_rate before insert on public.comments for each row execute function public.rate_limit();

-- vista pública con nombre del autor (sin exponer emails)
create view public.comments_view with (security_invoker=false) as
 select c.*, p.name as author_name from public.comments c join public.profiles p on p.id=c.user_id;
grant select on public.comments_view to anon, authenticated;

alter table public.profiles enable row level security;
alter table public.comments enable row level security;
alter table public.reports enable row level security;
alter table public.subscribers enable row level security;
create policy "perfil propio lectura" on public.profiles for select using (id=auth.uid());
create policy "leer comentarios" on public.comments for select using (true);
create policy "comentar logueado" on public.comments for insert to authenticated with check (user_id=auth.uid());
create policy "editar propio" on public.comments for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "borrar propio o admin" on public.comments for delete to authenticated using (user_id=auth.uid() or public.is_admin());
create policy "reportar" on public.reports for insert to authenticated with check (user_id=auth.uid());
create policy "admin ve reportes" on public.reports for select using (public.is_admin());
create policy "suscribirse" on public.subscribers for insert to anon, authenticated with check (true);
-- nadie puede leer subscribers desde el cliente (solo tú en el dashboard / Edge Functions con service key)
-- Hazte admin tras tu primer login:  update public.profiles set is_admin=true where id=(select id from auth.users where email='TU_CORREO');
