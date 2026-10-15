-- Docházka: skupiny, svěřenci, tréninky a docházka.
-- Spusť v Supabase: SQL Editor → New query → vložit → Run. (Po 1-schema.sql, používá funkci je_trener.)

create table if not exists skupiny (
  id            uuid primary key default gen_random_uuid(),
  nazev         text not null,
  trener_email  text,
  aktivni       boolean not null default true,
  created_at    timestamptz not null default now()
);

create table if not exists sverenci (
  id          uuid primary key default gen_random_uuid(),
  jmeno       text not null,
  prijmeni    text,
  rocnik      int,
  kategorie   text,
  skupina_id  uuid references skupiny(id) on delete set null,
  aktivni     boolean not null default true,
  poznamka    text,
  created_at  timestamptz not null default now()
);
create index if not exists sverenci_skupina_idx on sverenci(skupina_id);

create table if not exists treninky (
  id          uuid primary key default gen_random_uuid(),
  skupina_id  uuid not null references skupiny(id) on delete cascade,
  datum       date not null default current_date,
  nekonal     boolean not null default false,  -- trénink nebyl
  napln       text[] not null default '{}',   -- rychlé volby: voda, ergometr…
  napln_text  text,                           -- podrobnosti
  poznamka    text,
  created_by  text default (auth.jwt() ->> 'email'),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (skupina_id, datum)
);

create table if not exists dochazka (
  trenink_id   uuid not null references treninky(id) on delete cascade,
  sverenec_id  uuid not null references sverenci(id) on delete cascade,
  stav         text not null check (stav in ('byl','omluven','chybel')),
  primary key (trenink_id, sverenec_id)
);

alter table skupiny  enable row level security;
alter table sverenci enable row level security;
alter table treninky enable row level security;
alter table dochazka enable row level security;

drop policy if exists skupiny_vse on skupiny;
create policy skupiny_vse on skupiny for all to authenticated using (je_trener()) with check (je_trener());
drop policy if exists sverenci_vse on sverenci;
create policy sverenci_vse on sverenci for all to authenticated using (je_trener()) with check (je_trener());
drop policy if exists treninky_vse on treninky;
create policy treninky_vse on treninky for all to authenticated using (je_trener()) with check (je_trener());
drop policy if exists dochazka_vse on dochazka;
create policy dochazka_vse on dochazka for all to authenticated using (je_trener()) with check (je_trener());

-- Doplnění pro starší instalace (bezpečné spustit opakovaně):
alter table treninky add column if not exists nekonal boolean not null default false;
