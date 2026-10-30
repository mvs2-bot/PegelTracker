# PegelTracker

Single-File-Web-App (PWA) für Promille und Koffein, gehostet über GitHub Pages.
Nutzt das gemeinsame Supabase-Core-Projekt (Login und Profil wie TravelBase und Questlog).

## Dateien

| Datei | Inhalt |
| --- | --- |
| `index.html` | die komplette App (eigenes CSS, Chart.js und supabase-js über CDN) |
| Datenbank | Migration `…_pegeltracker_core` im Repo `supabase-core` (Tabellen, Zugriffsregeln, RPC) |
| `manifest.json`, `sw.js`, `icon.svg` | PWA: installierbar, App-Hülle offline verfügbar |
| `icons/` | App-Icons (Startbildschirm, maskable, Apple, Favicon) |

## Design

Gleiche Apple-Designsprache wie das Dashboard (mvs2-bot.github.io), „Zuhause“ und DailyMind: Systemschrift (SF),
Schriften 12–22 px (Basis 14 px), weiße Karten auf `#f2f2f7`, im Dunkeln dunkelgraue Karten (`#1c1c1e`) auf Schwarz,
Linien-Symbole statt Emojis (SVG-Sprite oben im `<body>`). Alle Farben stehen als CSS-Variablen in `:root` und `.dark`.

- Akzent Bernstein: Text und Symbole `#b45309`, Flächen `#f2b445` mit dunkler Schrift (dunkel `#f5b445`), Koffein Braun `#8a5a2b` (dunkel `#d4a373`).
- Pegelstufen `--lv0` … `--lv4` von Grün (nüchtern) bis Rot (ab 1,1 ‰).
- Bei Änderungen an Dateien die Cache-Version in `sw.js` hochzählen.

## Einrichtung

1. Migration `…_pegeltracker_core` aus `supabase-core` im Core-Projekt einspielen. Registriert die App `pegeltracker`.
2. Im Dashboard unter Admin-Einstellungen Ines für den PegelTracker als **Mitglied** freischalten.
   Globale Admins haben automatisch Admin-Rechte.
3. Im Profil (Kontoeinstellungen) Geschlecht, Größe, Gewicht und Geburtsdatum pflegen. Fehlt etwas, rechnet die App mit Standardwerten und zeigt einen Hinweis.

## Rollen

- **Mitglied** sieht und bearbeitet nur die eigenen Getränke.
- **Admin** sieht zusätzlich über den Umschalter oben die Bereiche der Mitglieder (nur lesen).

Die Datenbank setzt das selbst durch (Row Level Security), nicht nur die Oberfläche.

## Berechnung

- **Alkohol:** Widmark-Formel mit Körperwasser nach Watson (Geschlecht, Alter, Größe, Gewicht):
  `‰ = Gramm Alkohol · 0,8 / (1,055 · Körperwasser)`.
  Resorption erster Ordnung (Halbwertszeit ca. 10 min nüchtern, ca. 40 min mit Essensgrundlage),
  Resorptionsdefizit 10 % bzw. 25 %. Mit Essen steigt der Pegel dadurch langsamer und erreicht ein niedrigeres,
  späteres Maximum (vgl. Jones & Jönsson 1994).
  Abbau nach Michaelis-Menten (Vmax 0,16 ‰/h, Km 0,05 ‰): oberhalb von ca. 0,3 ‰ praktisch konstant ~0,15 ‰/h
  wie bei Widmark, darunter langsamer. Alle Konstanten stehen oben im Skript in `MODEL`.
- **Koffein:** Ein-Kompartiment-Modell (Maximum nach ca. 45 min, Halbwertszeit 5 h).
  Angezeigt werden aktives Koffein, Tagesmenge und Verlauf im Chart; den Promillewert beeinflusst es nicht.
- **Session:** beginnt mit dem ersten Getränk mit Alkohol oder Koffein und läuft, bis rechnerisch 0,0 ‰ erreicht
  und das aktive Koffein unter 15 mg gefallen ist. Alles, was in diesem Zeitraum getrunken wird, gehört dazu.
  Reine Koffein-Sessions zeigen im Verlauf nur die Koffeinkurve und im Log das maximale aktive Koffein. Sessions werden aus den Getränken berechnet, nicht gespeichert.

Alle Werte sind Schätzungen und nicht geeignet, die Fahrtüchtigkeit zu beurteilen.
