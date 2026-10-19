-- Lets a logged in person delete their own account and everything attached to it.
create or replace function public.along_delete_account() returns void
language plpgsql security definer set search_path = public, auth as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'not logged in'; end if;
  delete from public.along_requests where from_user = me or to_user = me;
  delete from public.along_walks where user_id = me;
  delete from public.along_blocks where blocker_id = me or blocked_id = me;
  delete from public.along_reports where reporter_id = me;
  delete from public.along_profiles where user_id = me;
  delete from auth.users where id = me;
end $$;
revoke all on function public.along_delete_account() from public, anon;
grant execute on function public.along_delete_account() to authenticated;
