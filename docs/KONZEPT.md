# Labubu-App – Konzept

Stand: 13.11.2026 · Ziel: fertig zu **Weihnachten 2026** (Geschenk)

## Für wen

- Tochter, **5–6 Jahre, kann noch nicht lesen.**
- Läuft auf dem iPad.

Daraus folgen feste Regeln für das ganze Spiel:

| Regel | Umsetzung |
|---|---|
| **Kein Lesen nötig** | Jede Information als Bild, Emoji/Icon, Farbe, Animation oder Ton. Text höchstens als Deko, nie als einzige Info. |
| **Große Ziele** | Alles Antippbare mindestens ~90 pt groß, viel Abstand. |
| **Keine Strafe** | Labubu stirbt nie, läuft nie weg. Es wird höchstens traurig/müde und ist mit ein paar Tipps wieder glücklich. |
| **Sofortiges Feedback** | Jeder Tipp bewirkt sichtbar etwas: Wackeln, Glitzer, Geräusch. |
| **Zählen ohne Zahlen** | Fortschritt als sich füllende Symbole (z. B. 5 Herzen), keine Prozente. |
| **Eltern-Bereich versteckt** | Einstellungen/Zurücksetzen nur per langem Drücken in einer Ecke. |

## Spielablauf

```
Ei wärmen ──► Schlüpfen ──► Labubus Zimmer (Hauptbildschirm)
                                 │
          ┌──────────────┬───────┴──────┬───────────────┐
          ▼              ▼              ▼               ▼
      🍓 Pflegen    👗 Anziehen    🎮 Mini-Spiele   📒 Album
                                        │               ▲
                                        └── ⭐ Sterne ──┘ (neue Eier, Sticker, Outfits)
```

### 1. Ei & Schlüpfen (vorhanden, wird kindgerecht)
- Jeder Tipp zählt, auch schnelles Tippen.
- Das Ei bekommt mit der Zeit sichtbare Risse.
- Nach etwa 15–20 Tipps schlüpft Labubu, mit Animation, Konfetti und Ton.
- Die Prozent-Balken entfallen und werden durch ein wachsendes Herz/Sonne-Symbol ersetzt.

### 2. Pflegen (Tamagotchi-Kern)

Drei Bedürfnisse, dargestellt als große Symbole, die sich leeren:

| Bedürfnis | Symbol | So erfüllt sie es |
|---|---|---|
| Hunger | 🍓 | Essen aus einem Teller zum Mund ziehen |
| Laune | 💖 | Labubu streicheln oder kitzeln, mit ihm spielen |
| Müdigkeit | 🌙 | Lampe ausmachen, Labubu schläft und schnarcht |

- Bedürfnisse sinken langsam, auch wenn die App zu ist (z. B. in ~8 Stunden von voll auf leer).
- Labubu zeigt seine Stimmung im Gesicht: fröhlich, hungrig, müde, traurig.

### 3. Anziehen & Gestalten
- Kleiderschrank mit Bildern: Mützen, Schleifen, Brillen, Kleidchen.
- Ein Teil per Drag & Drop auf Labubu ziehen; durch Antippen wieder abnehmen.
- Wenn Zeit bleibt: Zimmer dekorieren (Hintergrund, Teppich).

### 4. Sammeln
- **Sterne ⭐** als einzige Währung, verdient durch Pflege und Mini-Spiele.
- Sterne schalten frei: neue Outfits, Sticker und **neue Eier**. Aus jedem Ei schlüpft ein anders gefärbtes Labubu.
- Das Album zeigt alle Labubus und Sticker. Was noch fehlt, ist als grauer Schatten zu sehen; so ist ohne Lesen klar, dass da noch etwas kommt.

### 5. Mini-Spiele (1–2 Stück)
- **Früchte fangen:** Labubu mit dem Finger hin- und herschieben und fallende Erdbeeren fangen.
- **Memory:** wenige Karten (6–8) mit Labubu-Bildern.
- Keine Verlierer-Bildschirme; am Ende gibt es immer Sterne.

## Grafik & Ton
- **Bilder:** KI-generiert, in einem einheitlichen Stil.
  - Zuerst legen wir *ein* Referenzbild für den Stil fest, alle weiteren Bilder bauen darauf auf.
  - Format: PNG mit transparentem Hintergrund.
- **Töne:** kurze Effekte (Plopp, Kichern, Schnarchen, Schlüpf-Fanfare).
- **Optional:** kurze gesprochene Hinweise, z. B. „Labubu hat Hunger!“, vom iPad vorgelesen oder von dir eingesprochen. Für ein Kind, das nicht liest, ist das sehr hilfreich.
- **Rechte:** Labubu ist eine Marke von Pop Mart. Als private App ist das unproblematisch, für den App Store kommt sie nicht in Frage.

## Fahrplan bis Weihnachten

Jede Woche endet mit einer spielbaren Version. Was nicht fertig wird, fällt weg, ohne dass der Rest leidet.

| Woche | bis | Inhalt |
|---|---|---|
| ✅ 1 | 20.11. | Ei-Phase kindgerecht (Tippen, Risse, Schlüpf-Animation, Ton), **Spielstand speichern**, Grafik-Stil festlegen + erste Bilder |
| ✅ 2 | 27.11. | Labubus Zimmer + **Pflegen** (3 Bedürfnisse, Füttern, Streicheln, Schlafen, Stimmungs-Gesichter) |
| 3 | 04.12. | **Anziehen** (Kleiderschrank, Drag & Drop) + Sterne verdienen |
| 4 | 11.12. | **Sammeln** (Album, Sticker, weitere Eier/Labubus) |
| 5 | 18.12. | **Mini-Spiel** Früchte fangen (+ Memory, falls Zeit) |
| 6 | 23.12. | Feinschliff, Töne, auf das echte iPad installieren, Probelauf |

**Wenn es eng wird, fällt in dieser Reihenfolge weg:** Memory → Zimmer dekorieren → weitere Eier.

## Offene Punkte
- **Aufs echte iPad bringen:** Mit einem kostenlosen Apple-Account läuft eine selbst installierte App nur **7 Tage** und muss dann neu aus Xcode installiert werden. Damit sie dauerhaft läuft, brauchst du einen Apple-Developer-Account (99 €/Jahr), am besten über TestFlight. Spätestens in Woche 5 entscheiden.
- **Name des Labubus:** fest vorgegeben, oder darf sie ihn wählen? Ohne Lesen ginge das z. B. über eine Auswahl aus Bildern.
