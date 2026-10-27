begin;

create or replace function public.set_default_auth_user_role()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  trusted_role text;
begin
  trusted_role := case
    when new.raw_app_meta_data ->> 'role' = 'admin' then 'admin'
    else 'user'
  end;

  new.raw_app_meta_data := coalesce(new.raw_app_meta_data, '{}'::jsonb)
    || jsonb_build_object('role', trusted_role);

  return new;
end;
$$;

revoke all on function public.set_default_auth_user_role()
  from public, anon, authenticated;

drop trigger if exists set_default_auth_user_role on auth.users;

create trigger set_default_auth_user_role
before insert on auth.users
for each row
execute function public.set_default_auth_user_role();

update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
  || jsonb_build_object(
    'role',
    case
      when raw_app_meta_data ->> 'role' = 'admin' then 'admin'
      else 'user'
    end
  )
where raw_app_meta_data ->> 'role' is distinct from case
  when raw_app_meta_data ->> 'role' = 'admin' then 'admin'
  else 'user'
end;

commit;
