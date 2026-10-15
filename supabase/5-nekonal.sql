-- Docházka: stav „trénink nebyl“. Spusť jednou v SQL Editoru (bezpečné i opakovaně).
alter table treninky add column if not exists nekonal boolean not null default false;
