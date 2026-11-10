# mvs2 UI-Kit (Entwurf v1)

Gemeinsames Design-System für alle Webseiten. Erstes Beispiel: `entwurf/index.html` im PegelTracker.
Vorlage war das DrinkLog-Mockup; viele Muster stammen bewusst aus Instagram/Facebook, weil sie vertraut sind.

## Grundsatz

Die **Designsprache bleibt die bisherige**, also Systemschrift, Schriftgrößen 12–22 px (Basis 14 px), Überschriften 15 px/600, Labels 12 px/500, weiße Karten (Radius 18 px, Innenabstand 16 px) auf `#f2f2f7`, Abstände 14 px, der Sticky-Kopf oben und die iOS-Segmente.
Neu ist nur die **Anordnung**: Tab-Leiste unten am Handy, ein großer Haupt-Button pro Ansicht, Kennzahl-Kacheln, Auswahl-Raster, Stories-Leiste und Zähler.

## Einbinden

```html
<link rel="stylesheet" href="shared/ui-kit.css">
<body class="ds has-tabbar">
```

Pro App nur den Akzent setzen (Standard ist das PegelTracker-Gold):

```css
:root { --ds-accent: #b45309; --ds-accent-fill: #f2b445; --ds-accent-soft: #fdf0e1; --ds-on-accent: #1c1c1e; }
```

Dunkles Design wie bisher über die Klasse `.dark` an `<html>` (localStorage `overall-theme`).

## Regeln

1. **Kopf bleibt oben fixiert** (`.ds-header` mit `.ds-bar`), auf dem Handy und am Desktop.
2. **Handy: Tab-Leiste unten** (`.ds-tabbar`) mit 5 Zielen und rundem Plus in der Mitte, nur unter 768 px (Media Query). Unter jedem Symbol steht eine kurze Beschriftung.
3. **Desktop: Bedienung wie bisher**, mit den iOS-Segmenten (`.ds-seg.ds-tabs`) unter dem Kopf und dem Kontomenü oben rechts. Helfer: `.ds-mobile-only`, `.ds-desktop-only`.
4. **Ein Haupt-Button pro Ansicht** (`.ds-btn-main`): volle Breite, 52 px, Akzentfläche. Er sitzt im Daumenbereich (`.ds-sticky-cta`) und nennt vorab, was passiert.
5. **Rückmeldung mit Rückgängig** (`.ds-toast`) statt Bestätigungsdialog.
6. Touch-Ziele mindestens 34–44 px, Linien-Symbole (`.ds-ic`) statt Emojis.

## Bausteine

| Klasse | Wofür |
| --- | --- |
| `.ds-header`, `.ds-bar`, `.ds-actions`, `.ds-icon-btn` | Kopf (wie bisher) |
| `.ds-seg`, `.ds-tabs` | iOS-Segmente, Desktop-Navigation |
| `.ds-tabbar`, `.ds-tab-new` | Tab-Leiste unten (nur Handy) |
| `.ds-card`, `.ds-card-head`, `.ds-badge`, `.ds-stack`, `.ds-eyebrow`, `.ds-hint` | Karten (wie bisher) |
| `.ds-tiles`, `.ds-tile`, `.ds-meter` | Kennzahl-Kacheln |
| `.ds-btn-main`, `.ds-btn`, `.ds-sticky-cta` | Buttons |
| `.ds-chips`, `.ds-chip`, `.ds-pill`, `.ds-live` | Pillen und Status |
| `.ds-list`, `.ds-thumb`, `.ds-item`, `.ds-sep`, `.ds-ava` | Listen und Menüzeilen |
| `.ds-stories`, `.ds-story` | Stories-Leiste „Nochmal“ |
| `.ds-picks`, `.ds-pick` | Auswahl-Raster mit Häkchen |
| `.ds-stepper` | Plus/Minus-Zähler |
| `.ds-toggle`, `.ds-switch`, `.ds-note`, `.ds-toast`, `.ds-me`, `.ds-menu` | Schalter, Hinweis, Snackbar, Kontomenü |

Wird das Kit übernommen, kommt das Original (wie `ios-nav.js`) ins Repo `mvs2-bot.github.io` unter `shared/` und jede Seite bekommt eine Kopie.
