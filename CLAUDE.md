# CLAUDE.md – PegelTracker

Single-File-PWA (Promille + Koffein), gehostet über GitHub Pages unter `/PegelTracker/`.
Kein Build, kein npm: reines HTML/CSS/JS, Bibliotheken per CDN. Sprache in UI, Kommentaren und Commits: Deutsch.

## Arbeitsweise (Token-Effizienz)
- Nicht das ganze Repo einlesen. `index.html` hat ~2000 Zeilen: per `grep -n` die Stelle finden, dann gezielt Ausschnitte lesen.
- Vor dem PR selbst prüfen: Syntax (JS in `<script>`), kaputte IDs/Referenzen, Design-Konsistenz mit den Tokens unten.
- Bei Änderung an Architektur, Dateistruktur oder Schema diese Datei im selben PR anpassen (max. 150 Zeilen).
- Keine Secrets eintragen. Erlaubt ist nur der öffentliche Publishable Key; niemals `service_role`/secret Key.

## Dateien
| Datei | Inhalt |
| --- | --- |
| `index.html` | komplette App: CSS (Z. ~20–475), Markup/Views (~480–825), Skript (~826–Ende) |
| `sw.js` | Service Worker. **Bei jeder Änderung an gecachten Dateien `V` (z. B. `pegeltracker-v30`) hochzählen.** |
| `manifest.json`, `icon.svg`, `icons/` | PWA-Icons und Manifest |
| `shared/ios-nav.js` | Kopie aus `mvs2-bot.github.io/shared/` (Zurück/Neu-laden-Leiste für iOS-Web-App). Nur im Original ändern. |
| `shared/ui-kit.css`, `shared/UI-KIT.md` | neues UI-Kit (Entwurf v1, Klassen `.ds-*`), noch nicht in `index.html` übernommen |
| `entwurf/index.html` | Demo des neuen Kartendesigns mit Beispieldaten (speichert nichts) |
| `docs/entwurf/*.png` | Screenshots des Entwurfs |
| `README.md` | Nutzerdoku inkl. Berechnungsmodell |

## Aufbau von `index.html`
- Views als `<section id="…View">`: `loadView`, `loginView`, `noAccessView` (Gates); `addView`, `dashView`, `bfView` (Nachtragen), `histView`, `profileView`. Umschalten über `setTab(t)`.
- Theme: Inline-Skript im `<head>` setzt `.dark` an `<html>` aus `localStorage['overall-theme']`; `applyTheme(dark, save)`.
- Zustand im Objekt `S` (`user`, `role`, `people`, `viewId`, `drinks`, `custom`, …); `render()` zeichnet alles neu, `recompute()` rechnet Sessions.
- Hilfen: `$()` Selektor, `check(res)` wirft bei Supabase-Fehler, `withTimeout(p, ms)`, `flash(text, ok)`, `banner(html)`, `errorText(e)`.
- Rechenmodell: Konstanten in `MODEL`; `bodyModel` (Körperwasser 0,73 · fettfreie Masse bei `body_fat_pct`, sonst Watson), `simulate`, `buildSessions`, `zeroTime`, `cafEndTime`, `milestoneTime`.
- Charts: Chart.js über `chartConfig()`, `renderLiveChart()`, `renderHistory()`.
- Uhrzeit-Auswahl: eigenes Wheel-Picker-Widget (`mountWhen`).

## Supabase-Anbindung
- Gemeinsames Core-Projekt (alle Apps von mvs2-bot), Client: `supabase.createClient(PT_CONFIG.url, PT_CONFIG.key, …)`.
- supabase-js `2.45.4` und Chart.js `4.4.1` über jsDelivr (gleiche URLs in `sw.js` → `EXTRA`).
- **Schema liegt ausschließlich im Repo `supabase-core`** (Migration `20261020101500_pegeltracker_core.sql`). Schemaänderungen = neue Migration dort, eigener PR.
- Tabellen:
  - `pegel_drinks` (id, user_id, consumed_at, name, category, volume_ml, abv, caffeine_mg, with_food, note, created_at)
  - `pegel_custom_drinks` (id, user_id, name, category, volume_ml, abv, caffeine_mg, created_at; unique `user_id,name`)
  - `category` ∈ beer, wine, sparkling, cocktail, shot, spirit, caffeine, other
- RPCs: `overall_app_role('pegeltracker')`, `pegel_people()` (Admin-Umschalter), Helfer `pegel_is_member()`, `pegel_is_admin()`.
- Global genutzt: `overall_profiles` (gender, birthday, height_cm, weight_kg, optional `body_fat_pct` über `pegel_people()`, display_name, avatar_path), Storage-Bucket `avatars` (signierte URLs).
- Rollen: Mitglied = nur eigene Getränke; Admin = zusätzlich Mitglieder lesen. Durchgesetzt per RLS, nicht nur UI.
- Sessions werden aus Getränken berechnet, nicht gespeichert.

## Design-Tokens (`:root`, dunkel unter `.dark`)
- Flächen: `--bg #f2f2f7`, `--card #fff`, `--well`, `--hover`, `--line`, `--sep`; dunkel Karten `#1c1c1e` auf Schwarz.
- Text: `--ink #1c1c1e`, `--text #3a3a3c`, `--mute #6c6c70`.
- Akzent Bernstein: `--p1 #b45309` (Text/Symbole), `--p1-fill #f2b445` (Flächen), `--p1-soft #fdf0e1`, `--on-p1 #1c1c1e`.
- Koffein: `--caf #8a5a2b`, `--caf-soft`. Status: `--ok`, `--danger`, `--warn` (+ `-soft`).
- Pegelstufen `--lv0` … `--lv4` (Grün → Rot; Grenzen 0 / <0,3 / 0,3 / 0,5 / 1,1 ‰), Zuordnung in `bacColor()`.
- `--radius 18px`, `--radius-s 12px`, `--shadow`, `--pop`, `--font` (Systemschrift/SF).
- Aliasse für `ios-nav.js`: `--border`, `--accent`, `--card-hover`, `--muted`.
- Typo: 12–22 px, Basis 14 px; Überschriften 15 px/600, Labels 12 px/500. Karten Radius 18, Padding 16, Abstände 14.
- Symbole: Linien-SVGs aus dem Sprite oben im `<body>`, keine Emojis. Touch-Ziele ≥ 34–44 px.

## Konventionen
- Neue Farben immer als Variable in `:root` **und** `.dark`, nie hart im Markup.
- Geteilte Dateien (`shared/ios-nav.js`, `overall-account.js`) nur im Original-Repo ändern und dann kopieren.
- Keine Bestätigungsdialoge; Rückmeldung per `flash()` / Toast.
- Alle Werte sind Schätzungen; Hinweis zur Fahrtüchtigkeit beibehalten.
