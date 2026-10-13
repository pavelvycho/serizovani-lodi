-- Seřízení lodí – databáze lodí, sad vesel a seřízení
-- Spusť celé v Supabase: SQL Editor → New query → vložit → Run.

-- ---------- tabulky ----------
create table if not exists treneri (
  email  text primary key,
  jmeno  text,
  admin  boolean not null default false
);

create table if not exists lode (
  id           uuid primary key default gen_random_uuid(),
  nazev        text,
  typ          text not null,             -- 1x, 2x, 2-, 4x-, 4x+, 8+ …
  typ_alt      text,                      -- druhé použití (např. 8x+ u osmy)
  velikost     text,                      -- skif, dvojskif, čtyřka "s" …
  vyrobce      text,
  barva        text,
  rok          int,
  kategorie    text,
  nosnost_min  int,
  nosnost_max  int,
  stav         text not null default 'v provozu'
               check (stav in ('v provozu','v garáži','nepojízdná','vyřazená')),
  alt_krakorce boolean not null default false,  -- má i druhou sadu krakorců
  poznamka     text,
  updated_at   timestamptz not null default now(),
  updated_by   text
);

create table if not exists sady_vesel (
  id         uuid primary key default gen_random_uuid(),
  nazev      text not null,
  druh       text not null check (druh in ('párová','nepárová')),
  lopatka    text not null check (lopatka in ('sekera','Macon')),
  paru       int,
  kategorie  text,
  delka_min  numeric, delka_max numeric,  -- rozsah stavitelné délky, cm
  paka_min   numeric, paka_max  numeric,  -- rozsah vnitřní páky, cm
  poznamka   text,
  updated_at timestamptz not null default now(),
  updated_by text
);

create table if not exists serizeni (
  id                uuid primary key default gen_random_uuid(),
  lod_id            uuid not null references lode(id) on delete cascade,
  datum             date not null default current_date,
  rozpeti           numeric,   -- párové, cm
  vylozeni          numeric,   -- nepárové, cm
  paka              numeric,   -- vnitřní páka, cm
  delka_vesla       numeric,   -- cm
  sada_id           uuid references sady_vesel(id) on delete set null,
  havlinka_p        numeric,   -- výška nad sedátkem, cm (u nepárových jediná hodnota)
  havlinka_l        numeric,
  pata_od_osy       numeric,   -- + k zádi, cm
  hloubka_pat       numeric,
  uhel_nohavek      numeric,
  kolejnicky_zad    numeric,   -- začátek kolejniček, + k zádi od osy havlinky
  kolejnicky_spicka numeric,   -- konec kolejniček, cm ke špičce od osy havlinky
  nakolmeni         text,
  poznamka          text,
  created_at        timestamptz not null default now(),
  created_by        text default (auth.jwt() ->> 'email')
);
create index if not exists serizeni_lod_idx on serizeni(lod_id, datum desc);

-- ---------- kdo je trenér ----------
create or replace function je_trener() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from treneri
                 where lower(email) = lower(coalesce(auth.jwt() ->> 'email','')));
$$;

-- ---------- kdo a kdy upravil ----------
create or replace function nastav_upravu() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  new.updated_by := auth.jwt() ->> 'email';
  return new;
end $$;

drop trigger if exists lode_uprava on lode;
create trigger lode_uprava before insert or update on lode
  for each row execute function nastav_upravu();
drop trigger if exists sady_uprava on sady_vesel;
create trigger sady_uprava before insert or update on sady_vesel
  for each row execute function nastav_upravu();

-- ---------- přístup: jen trenéři ze seznamu ----------
alter table treneri    enable row level security;
alter table lode       enable row level security;
alter table sady_vesel enable row level security;
alter table serizeni   enable row level security;

drop policy if exists treneri_cteni on treneri;
create policy treneri_cteni on treneri for select to authenticated using (je_trener());

drop policy if exists lode_vse on lode;
create policy lode_vse on lode for all to authenticated using (je_trener()) with check (je_trener());

drop policy if exists sady_vse on sady_vesel;
create policy sady_vse on sady_vesel for all to authenticated using (je_trener()) with check (je_trener());

drop policy if exists serizeni_vse on serizeni;
create policy serizeni_vse on serizeni for all to authenticated using (je_trener()) with check (je_trener());

-- ---------- první trenér (ty) ----------
-- Nahraď e-mail svým a spusť. Další trenéry přidáš v Table Editor → treneri → Insert row.
insert into treneri (email, jmeno, admin) values ('TVUJ@EMAIL.CZ', 'Správce', true)
  on conflict (email) do nothing;
