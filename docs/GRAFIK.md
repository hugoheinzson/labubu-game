# Grafiken mit Bild-KI erstellen

Die App läuft schon ohne Bilder: Ei und Labubu sind als Platzhalter gezeichnet. Sobald eine PNG-Datei mit dem richtigen Namen in `Sources/LabubuApp/Resources/` liegt, wird sie automatisch statt des Platzhalters angezeigt.

## Vorgehen

1. **Stil festlegen:** Zuerst nur das Baby-Labubu erzeugen, bis ein Bild richtig gefällt. Das ist das *Referenzbild*.
2. **Alles Weitere vom Referenzbild ableiten:** Bei jeder neuen Grafik das Referenzbild mitgeben und den Satz „im exakt gleichen Stil wie das Referenzbild“ ergänzen. So bleibt alles einheitlich.
3. **Hintergrund entfernen:** Die KI-Bilder brauchen einen transparenten Hintergrund (PNG). Viele Bild-KIs können das direkt. Sonst geht es z. B. mit macOS Vorschau → Werkzeuge → Sofort-Alpha oder mit „Objekt freistellen“ in der Fotos-App.

## Technische Vorgaben

| Datei | Inhalt | Format |
|---|---|---|
| `BabyLabubu.png` | Baby-Labubu, frontal, ganzer Körper, steht/sitzt | PNG, transparent, ca. 1024 × 1300 px, Seitenverhältnis ~4:5 |
| `EggClosed.png` | Das geschlossene Ei, frontal | PNG, transparent, ca. 1024 × 1300 px, Seitenverhältnis ~4:5 |
| `BabyLabubu-hungry.png` | Labubu mit weit offenem Mund, sabbert ein bisschen | wie `BabyLabubu.png`, gleiche Pose und Größe |
| `BabyLabubu-tired.png` | halb geschlossene Augen, gähnt | wie oben |
| `BabyLabubu-sad.png` | traurig, kleine Träne | wie oben |
| `BabyLabubu-sleeping.png` | Augen zu, schläft im Stehen/Sitzen | wie oben |

Die Stimmungsbilder sind optional. Fehlt eines, zeigt die App `BabyLabubu.png` (dann sieht man die Stimmung nur an der Denkblase).

- Die Figur soll das Bild ausfüllen, mit nur wenig Rand.
- Keinen Schatten auf den Boden zeichnen lassen, den fügt die App selbst hinzu.
- Risse und Aufbrechen des Eis zeichnet die App selbst darüber, das Ei muss also heil sein.

## Prompt-Vorschläge

**Referenzbild – Baby-Labubu**
> Cute baby monster character for a children's game, full body, front view, standing. Fluffy pastel beige fur, tall bunny-like ears with pink inside, big round shiny black eyes, rosy cheeks, wide happy grin showing a row of small pointy white teeth. Soft 3D vinyl toy look, rounded shapes, gentle studio lighting, pastel colors. Isolated on a transparent background, no shadow, no text.

**Ei**
> In exactly the same style as the reference image: a large fluffy pastel egg with soft polka dots in mint, pink and lavender, front view, whole egg, no cracks. Isolated on a transparent background, no shadow, no text.

**Stimmungen** (jeweils mit Referenzbild):
> Exactly the same character, same pose, same size and framing as the reference image, but [hungry with its mouth wide open | very sleepy with half-closed eyes, yawning | sad with a small tear | fast asleep with closed eyes]. Transparent background, no shadow, no text.

**Kleidung:** Aktuell sind die Kleidungsstücke Emojis, die über Labubu gelegt werden (Positionen in `Views/Components/OutfitLayer.swift`). Das funktioniert auch mit einem KI-Labubu, die Positionen müssen dann ggf. leicht nachjustiert werden.

Für später (Woche 4) nach demselben Muster: weitere Labubus in anderen Fellfarben.
