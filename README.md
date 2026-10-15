# Seřízení veslařské lodi

Kalkulačka výchozího seřízení veslařské lodi pro trenéry. Podle kategorie (žactvo, dorost, junioři, dospělí), pohlaví, lodi a mír veslaře navrhne:

- délku vesla, vnitřní páku a převod,
- rozpětí / vyložení a výšku havlinek,
- polohu, hloubku a úhel nohavek,
- začátek a konec kolejniček,
- společné nastavení posádky a individuální nastavení každého místa.

Je to jeden statický web (HTML + CSS + JS bez knihoven a bez buildu). Funguje offline a dá se „nainstalovat“ na plochu telefonu.

## Lodě a vesla

Stránka `lode.html` (záložky **Lodě** a **Vesla**) je společná evidence lodí, sad vesel a seřízení pro celý klub. Data jsou v databázi Supabase, přístup mají jen trenéři ze seznamu. Nastavení: `supabase/NAVOD.md`. V kalkulačce tlačítko **Zapsat do lodi** přenese spočítané seřízení do vybrané lodi.

## Docházka

Stránka `dochazka.html`: zápis tréninku (byl / omluven / chyběl, náplň, poznámka), přehled účasti za období s procenty a export do Excelu (CSV), správa svěřenců a skupin. Data v Supabase, nastavení v `supabase/NAVOD.md`.

## Výkony

Stránka `vykony.html`: karta svěřence (biometrie, osobní rekordy, historie s grafem, body SCM, odkaz do kalkulačky), hromadný zápis výsledků a biometrie, porovnání podle disciplíny a termínu. Disciplíny si trenéři rozšiřují sami. Body SCM podle `scm-normy-2026.js`.

## Správa

Stránka `sprava.html` jen pro správce: trenéři a přehled přihlášení, skupiny, disciplíny, měsíční přehled klubu. SQL: `supabase/8-sprava.sql`.

## Data kalkulačky

Svěřenci a rozsahy vesel v kalkulačce se ukládají **do prohlížeče v zařízení** (localStorage). Každý trenér má svoje svěřence ve svém telefonu. Přenos mezi zařízeními nebo kolegovi: **Stáhnout zálohu svěřenců** → soubor `.json` → v druhém zařízení **Nahrát zálohu**.

Vymazání dat prohlížeče svěřence smaže, proto občas stáhni zálohu.

## Nasazení

### Vercel
1. Nahraj složku do nového repozitáře na GitHubu.
2. Ve Vercelu: **Add New → Project → Import** repozitáře. Framework: **Other**, bez build příkazu, výstupní složka je kořen.
3. Deploy. Každý push do `main` se nasadí automaticky.

### GitHub Pages (alternativa)
Repozitář → **Settings → Pages → Deploy from a branch → `main` / root**.

### Aktualizace
Po každé změně `index.html` zvyš v `sw.js` verzi `CACHE` (např. `serizeni-v2`). Telefony pak při dalším otevření stáhnou novou verzi.

## Instalace do telefonu

- **Android (Chrome):** otevři adresu → menu ⋮ → **Přidat na plochu / Nainstalovat aplikaci**.
- **iPhone (Safari):** otevři adresu → tlačítko Sdílet → **Přidat na plochu**. (Musí to být Safari.)

## Zdroje

- Seřizování lodí – Labská akademie veslování (ČVS)
- Concept2 – Oar Length, Gearing and Rig; Sculls: Length and Rigging
- World Rowing – Practical Boat Rigging

Hodnoty pro žactvo, dorost a juniory a poloha nohavek z postavy jsou odvozené odhady, výchozí bod pro seřízení na vodě.
