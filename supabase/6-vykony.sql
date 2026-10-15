-- Výkony: disciplíny, biometrie a výsledky. Spusť po 3-dochazka.sql (bezpečné i opakovaně).

alter table sverenci add column if not exists pohlavi text not null default 'M' check (pohlavi in ('M','Z'));

create table if not exists discipliny (
  id          text primary key,              -- např. trenazer2000
  nazev       text not null,
  kategorie   text not null,                 -- trenažér, voda, běh, síla, skok, plavání
  typ         text not null check (typ in ('cas','cislo')),
  jednotka    text,                          -- u čísel: cm, J, opak.
  lepsi       text not null check (lepsi in ('nizsi','vyssi')),
  vzdalenost  int,                           -- m, pro tempo na 500 m
  scm         text,                          -- klíč testu v normách SCM
  poradi      int not null default 100,
  aktivni     boolean not null default true
);

create table if not exists biometrie (
  id           uuid primary key default gen_random_uuid(),
  sverenec_id  uuid not null references sverenci(id) on delete cascade,
  datum        date not null default current_date,
  vyska        numeric, vaha numeric, rozpeti numeric,
  poznamka     text,
  created_by   text default (auth.jwt() ->> 'email'),
  created_at   timestamptz not null default now()
);
create index if not exists biometrie_sv_idx on biometrie(sverenec_id, datum desc);

create table if not exists vysledky (
  id             uuid primary key default gen_random_uuid(),
  sverenec_id    uuid not null references sverenci(id) on delete cascade,
  disciplina_id  text not null references discipliny(id) on update cascade,
  datum          date not null default current_date,
  hodnota        numeric not null,             -- čas v sekundách, jinak číslo
  poznamka       text,
  created_by     text default (auth.jwt() ->> 'email'),
  created_at     timestamptz not null default now()
);
create index if not exists vysledky_sv_idx on vysledky(sverenec_id, disciplina_id, datum desc);
create index if not exists vysledky_disc_idx on vysledky(disciplina_id, datum);

alter table discipliny enable row level security;
alter table biometrie  enable row level security;
alter table vysledky   enable row level security;
drop policy if exists discipliny_vse on discipliny;
create policy discipliny_vse on discipliny for all to authenticated using (je_trener()) with check (je_trener());
drop policy if exists biometrie_vse on biometrie;
create policy biometrie_vse on biometrie for all to authenticated using (je_trener()) with check (je_trener());
drop policy if exists vysledky_vse on vysledky;
create policy vysledky_vse on vysledky for all to authenticated using (je_trener()) with check (je_trener());

insert into discipliny (id, nazev, kategorie, typ, jednotka, lepsi, vzdalenost, scm, poradi) values
  ('trenazer500',  'Trenažér 500 m',  'trenažér','cas',  null,   'nizsi', 500,  null,          10),
  ('trenazer2000', 'Trenažér 2000 m', 'trenažér','cas',  null,   'nizsi', 2000, 'trenazer2000',11),
  ('trenazer6000', 'Trenažér 6000 m', 'trenažér','cas',  null,   'nizsi', 6000, null,          12),
  ('voda500',      'Voda 500 m',      'voda',    'cas',  null,   'nizsi', 500,  null,          20),
  ('voda1500',     'Voda 1500 m',     'voda',    'cas',  null,   'nizsi', 1500, null,          21),
  ('voda2000',     'Voda 2000 m',     'voda',    'cas',  null,   'nizsi', 2000, null,          22),
  ('voda3000',     'Voda 3000 m',     'voda',    'cas',  null,   'nizsi', 3000, null,          23),
  ('voda6000',     'Voda 6000 m',     'voda',    'cas',  null,   'nizsi', 6000, null,          24),
  ('beh3000',      'Běh 3000 m',      'běh',     'cas',  null,   'nizsi', null, 'beh3000',     30),
  ('beh50',        'Běh 50 m',        'běh',     'cislo','s',    'nizsi', null, 'beh50',       31),
  ('plavani200',   'Plavání 200 m',   'plavání', 'cas',  null,   'nizsi', null, 'plavani200',  40),
  ('pritrh',       'Přítrh 3 min',    'síla',    'cislo','J',    'vyssi', null, 'pritrh',      50),
  ('shyb',         'Shyb nadhmatem',  'síla',    'cislo','opak.','vyssi', null, 'shyb',        51),
  ('skok',         'Skok daleký snožmo','skok',  'cislo','cm',   'vyssi', null, 'skok',        60)
on conflict (id) do nothing;
