# 🍻 PegelTracker

Single-File-Web-App (PWA) für Promille und Koffein, gehostet über GitHub Pages.
Nutzt das gemeinsame Supabase-Core-Projekt (Login und Profil wie TravelBase und Questlog).

## Dateien

| Datei | Inhalt |
| --- | --- |
| `index.html` | die komplette App (Tailwind CSS, Chart.js, supabase-js über CDN) |
| `supabase/pegeltracker_core.sql` | Tabellen, Zugriffsregeln und RPC im Core-Projekt |
| `manifest.json`, `sw.js`, `icon.svg` | PWA: installierbar, App-Hülle offline verfügbar |

## Einrichtung

1. `supabase/pegeltracker_core.sql` im Core-Projekt ausführen (SQL Editor). Registriert die App `pegeltracker`.
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
- **Trinksession:** beginnt mit dem ersten alkoholischen Getränk und läuft, bis rechnerisch 0,0 ‰ erreicht sind.
  Alles, was davor getrunken wird, gehört dazu. Sessions werden aus den Getränken berechnet, nicht gespeichert.

Alle Werte sind Schätzungen und nicht geeignet, die Fahrtüchtigkeit zu beurteilen.
