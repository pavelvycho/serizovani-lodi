-- Správa: trenéři (jméno, příjmení, e-mail, správce), přehled přihlášení.
-- Spusť jednou v SQL Editoru (bezpečné i opakovaně).

-- příjmení zvlášť; stávající „Jméno Příjmení“ se rozdělí podle první mezery
alter table treneri add column if not exists prijmeni text;
update treneri set prijmeni = trim(substr(jmeno, strpos(jmeno, ' ') + 1)), jmeno = split_part(jmeno, ' ', 1)
  where prijmeni is null and jmeno like '% %';

create or replace function je_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from treneri
                 where admin and lower(email) = lower(coalesce(auth.jwt() ->> 'email','')));
$$;

-- e-mail vždy malými písmeny + pojistky proti zamčení
create or replace function treneri_kontrola() returns trigger
language plpgsql security definer set search_path = public as $$
declare ja text := lower(coalesce(auth.jwt() ->> 'email',''));
begin
  if tg_op in ('INSERT','UPDATE') then
    new.email := lower(trim(new.email));
  end if;
  if tg_op = 'DELETE' and lower(old.email) = ja then
    raise exception 'Nemůžeš odebrat sám sebe.';
  end if;
  if tg_op = 'UPDATE' and lower(old.email) = ja and old.admin and not new.admin then
    raise exception 'Nemůžeš si sám odebrat roli správce.';
  end if;
  if tg_op <> 'INSERT' and old.admin and (tg_op = 'DELETE' or not coalesce(new.admin, false))
     and (select count(*) from treneri where admin) <= 1 then
    raise exception 'Musí zůstat aspoň jeden správce.';
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end $$;

drop trigger if exists treneri_kontrola on treneri;
create trigger treneri_kontrola before insert or update or delete on treneri
  for each row execute function treneri_kontrola();

-- zápis do seznamu trenérů jen pro správce (číst mohou všichni trenéři)
drop policy if exists treneri_zapis on treneri;
create policy treneri_zapis on treneri for insert to authenticated with check (je_admin());
drop policy if exists treneri_uprava on treneri;
create policy treneri_uprava on treneri for update to authenticated using (je_admin()) with check (je_admin());
drop policy if exists treneri_mazani on treneri;
create policy treneri_mazani on treneri for delete to authenticated using (je_admin());

-- přehled přihlášení (jen pro správce)
create or replace function prehled_prihlaseni()
returns table (email text, posledni_prihlaseni timestamptz, prvni_prihlaseni timestamptz, ma_pristup boolean)
language plpgsql stable security definer set search_path = public, auth as $$
begin
  if not je_admin() then raise exception 'Jen pro správce.'; end if;
  return query
    select u.email::text, u.last_sign_in_at, u.created_at,
           exists (select 1 from public.treneri t where t.email = lower(u.email))
    from auth.users u
    order by u.last_sign_in_at desc nulls last;
end $$;
revoke all on function prehled_prihlaseni() from public, anon;
grant execute on function prehled_prihlaseni() to authenticated;
