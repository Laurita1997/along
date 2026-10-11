create table if not exists public.along_blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  blocked_name text,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
);
alter table public.along_blocks enable row level security;
create policy "see own blocks" on public.along_blocks for select to authenticated using (blocker_id = auth.uid());
create policy "block someone" on public.along_blocks for insert to authenticated with check (blocker_id = auth.uid() and blocked_id <> auth.uid());
create policy "unblock" on public.along_blocks for delete to authenticated using (blocker_id = auth.uid());

create table if not exists public.along_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reported_id uuid not null references auth.users(id) on delete cascade,
  reported_name text,
  reason text not null,
  created_at timestamptz not null default now()
);
alter table public.along_reports enable row level security;
create policy "send report" on public.along_reports for insert to authenticated with check (reporter_id = auth.uid());

create or replace function public.along_blocked(a uuid, b uuid) returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from public.along_blocks where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a))
$$;
grant execute on function public.along_blocked(uuid, uuid) to authenticated;

drop policy if exists "walks visible while active" on public.along_walks;
create policy "walks visible while active" on public.along_walks for select to authenticated
  using (user_id = auth.uid() or (off_at > now() and not public.along_blocked(auth.uid(), user_id)));

drop policy if exists "send request" on public.along_requests;
create policy "send request" on public.along_requests for insert to authenticated
  with check (from_user = auth.uid() and to_user <> auth.uid() and not public.along_blocked(auth.uid(), to_user));
