# Napojení databáze lodí (Supabase)

Lodě, sady vesel a seřízení jsou společné pro celý klub. Ukládají se do databáze Supabase (zdarma).
Vidí a upravují je jen trenéři, jejichž e-mail je v tabulce `treneri`.

## 1. Založ projekt
1. Na **supabase.com** → **Start your project** → přihlas se přes GitHub.
2. **New project**: název `serizeni-lodi`, vymysli heslo k databázi (ulož si ho), region **Central EU (Frankfurt)** → **Create new project**. Chvíli to trvá.

## 2. Vytvoř tabulky
1. Vlevo **SQL Editor** → **New query**.
2. Otevři `supabase/1-schema.sql`, na posledním řádku nahraď `TVUJ@EMAIL.CZ` svým e-mailem, vlož celé do editoru → **Run**. Má skončit „Success. No rows returned“.
3. Znovu **New query** → vlož celý `supabase/2-import.sql` → **Run**. Naimportuje 48 lodí a 14 sad vesel (bez jmen posádek).
4. Kontrola: vlevo **Table Editor** → `lode` má 48 řádků, `sady_vesel` 14.

## 3. Přihlašování kódem z e-mailu
1. **Authentication → Sign In / Providers → Email**: zapnuto (výchozí).
2. **Authentication → Emails → Templates**: v šablonách **Magic Link** i **Confirm signup** (ta chodí při úplně prvním přihlášení) přidej do těla řádek s kódem, např.
   ```
   <p>Tvůj kód pro přihlášení: <strong>{{ .Token }}</strong></p>
   ```
   (Kód se hodí hlavně na iPhonu – odkaz z e-mailu se otevře v Safari, ne v nainstalované aplikaci.)
3. **Authentication → URL Configuration**:
   - **Site URL**: `https://serizovani-lodi.vercel.app`
   - **Redirect URLs** → Add: `https://serizovani-lodi.vercel.app/**`

## 4. Připoj aplikaci
1. **Project Settings → API** (nebo Data API): zkopíruj **Project URL** a **anon public** klíč.
2. Na GitHubu otevři `config.js` → tužka → vlož obě hodnoty mezi uvozovky → **Commit changes**.
   Anon klíč smí být veřejný, data chrání pravidla v databázi.
3. Po nasazení otevři `https://serizovani-lodi.vercel.app/lode.html` a přihlas se svým e-mailem.

## Přidání trenéra
**Table Editor → treneri → Insert row**: e-mail (malými písmeny), jméno. Trenér se pak přihlásí sám.
Odebrání = smazat řádek. Kdo není v tabulce, po přihlášení nic neuvidí.

## Dobré vědět
- **Uspání projektu:** bezplatný projekt se po 7 dnech bez jediného přístupu uspí. V Supabase ho pak jedním klikem probudíš (**Restore**), data zůstanou. Při běžném používání se to nestane.
- **Počet e-mailů:** vestavěné posílání e-mailů má nízký hodinový limit. Pro pár trenérů stačí; kdyby se kódy nedoručovaly, nastav vlastní SMTP (Authentication → Emails → SMTP Settings).
- **Záloha:** Table Editor → tabulka → **Export to CSV**.

## Docházka
1. **SQL Editor → New query** → vlož `supabase/3-dochazka.sql` → **Run**. Vytvoří tabulky skupin, svěřenců, tréninků a docházky (přístup jen trenéři ze seznamu).
2. Svěřence naimportuj souborem s jejich jmény, který dostaneš zvlášť (není v repozitáři), nebo je přidej v aplikaci: **Docházka → Svěřenci a skupiny**.
3. Docházku vidí a zapisují všichni trenéři ze seznamu `treneri`.
4. Pro tlačítko „Nebyl trénink“ spusť jednou `supabase/5-nekonal.sql` (přidá sloupec `nekonal`). U nových instalací je už v `3-dochazka.sql`.

**Jména dětí do repozitáře nepatří.** Repozitář je veřejný – soubory se jmény nahrávej jen do Supabase. Pro jistotu můžeš repozitář přepnout na soukromý (GitHub → Settings → General → Danger Zone → Change visibility → Private); Vercel s ním funguje dál.

## Výkony
1. **SQL Editor → New query** → vlož `supabase/6-vykony.sql` → **Run**. Přidá tabulky disciplín, biometrie a výsledků, pohlaví u svěřenců a 14 výchozích disciplín.
2. Historické výsledky naimportuj souborem, který dostaneš zvlášť (obsahuje jména – na GitHub nepatří).
3. Body SCM se počítají z `scm-normy-2026.js` (tabulka ČVS 2026). Ročníky mimo tabulku se počítají podle nejbližšího ročníku. Na nový rok stačí přidat nový soubor s normami.
