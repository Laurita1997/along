create table if not exists public.along_walks (
  user_id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  age int not null check (age >= 18),
  has_dog boolean not null default false,
  dog_name text,
  breed text,
  photo text,
  plan text not null,
  mode text not null check (mode in ('pin','live')),
  lat double precision not null,
  lng double precision not null,
  start_at timestamptz not null,
  off_at timestamptz not null,
  updated_at timestamptz not null default now()
);
alter table public.along_walks enable row level security;
create policy "walks visible while active" on public.along_walks for select to authenticated using (off_at > now() or user_id = auth.uid());
create policy "own walk insert" on public.along_walks for insert to authenticated with check (user_id = auth.uid());
create policy "own walk update" on public.along_walks for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own walk delete" on public.along_walks for delete to authenticated using (user_id = auth.uid());

create table if not exists public.along_requests (
  id uuid primary key default gen_random_uuid(),
  from_user uuid not null references auth.users(id) on delete cascade,
  to_user uuid not null references auth.users(id) on delete cascade,
  from_name text not null,
  plan text,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now()
);
alter table public.along_requests enable row level security;
create policy "see own requests" on public.along_requests for select to authenticated using (from_user = auth.uid() or to_user = auth.uid());
create policy "send request" on public.along_requests for insert to authenticated with check (from_user = auth.uid() and to_user <> auth.uid());
create policy "answer request" on public.along_requests for update to authenticated using (to_user = auth.uid()) with check (to_user = auth.uid());
create policy "withdraw request" on public.along_requests for delete to authenticated using (from_user = auth.uid());
create index if not exists along_requests_to on public.along_requests (to_user);
create index if not exists along_requests_from on public.along_requests (from_user);
