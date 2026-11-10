# mvs2 UI-Kit (Entwurf v1)

Gemeinsames Design-System für alle Webseiten. Erstes Beispiel: `entwurf/index.html` im PegelTracker.
Vorlage war das DrinkLog-Mockup; viele Muster stammen bewusst aus Instagram/Facebook, weil sie vertraut sind.

## Einbinden

```html
<link rel="stylesheet" href="shared/ui-kit.css">
<body class="ds has-tabbar">
```

Pro App nur den Akzent setzen, z. B. PegelTracker:

```css
:root { --ds-accent: #dd760a; --ds-accent-soft: #fff0de; }
.dark { --ds-accent: #ffa94d; --ds-accent-soft: #2f2210; }
```

Dunkles Design wie bisher über die Klasse `.dark` an `<html>` (localStorage `overall-theme`).

## Regeln

1. **Ein Haupt-Button pro Ansicht** (`.ds-btn.primary`): gefüllt, dunkles Marineblau, mind. 52 px hoch. Alles andere ist `secondary`, `ghost` oder ein Chip.
2. **Handy: untere Tab-Leiste** (`.ds-tabbar`) mit 5 Zielen, in der Mitte ein runder Plus-Button. Erscheint nur unter 768 px Breite (Media Query in der CSS-Datei). Jedes Symbol hat eine kurze Beschriftung.
3. **Desktop: Bedienung wie gehabt**: obere Navigation (`.ds-topnav`) und Kontomenü oben rechts (`.ds-menu`). Helfer: `.ds-mobile-only`, `.ds-desktop-only`.
4. **Wichtigster Button im Daumenbereich**: `.ds-sticky-cta` hält „Speichern“ über der Tab-Leiste.
5. **Rückmeldung mit Rückgängig** (`.ds-toast`) statt Bestätigungsdialog.
6. Touch-Ziele mind. 44 px, Linien-Symbole (`.ds-ic`) statt Emojis, Zahlen mit `.ds-num`.

## Bausteine

| Klasse | Wofür |
| --- | --- |
| `.ds-header`, `.ds-brand`, `.ds-title`, `.ds-actions` | Kopfzeile |
| `.ds-topnav` | Tabs oben (Desktop) |
| `.ds-tabbar`, `.ds-tab-new` | Tab-Leiste unten (nur Handy) |
| `.ds-card`, `.ds-card-head`, `.ds-stack`, `.ds-section` | Karten und Abstände |
| `.ds-tiles`, `.ds-tile`, `.ds-meter` | Kennzahl-Kacheln mit großer Zahl |
| `.ds-btn` (`primary`, `secondary`, `ghost`, `danger`, `block`), `.ds-icon-btn` | Buttons |
| `.ds-chips`, `.ds-chip`, `.ds-seg`, `.ds-pill`, `.ds-live` | Auswahl-Chips, Segmente, Status |
| `.ds-list`, `.ds-row`, `.ds-thumb`, `.ds-ava` | Listen wie in den Einstellungen |
| `.ds-stories`, `.ds-story` | Stories-Leiste (z. B. „Nochmal trinken“) |
| `.ds-picks`, `.ds-pick` | Auswahl-Raster mit Häkchen |
| `.ds-stepper` | Plus/Minus-Zähler |
| `.ds-switch`, `.ds-note`, `.ds-hero`, `.ds-toast`, `.ds-menu` | Schalter, Hinweis, Leer-/Kopfkarte, Snackbar, Popover |

Wird das Kit übernommen, kommt das Original (wie `ios-nav.js`) ins Repo `mvs2-bot.github.io` unter `shared/` und jede Seite bekommt eine Kopie.
