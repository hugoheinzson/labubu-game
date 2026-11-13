# Grafikbestand und Weiterarbeit

Alle benötigten Kernbilder liegen in `Sources/LabubuApp/Resources/` und werden mit dem Swift Package ausgeliefert. Der freigegebene Stil ist ein braunes, flauschiges Labubu mit hellem Vinylgesicht. **`BabyLabubu.png` ist die verbindliche Referenz** – nicht den älteren generischen beigen Prompt als neue Stilvorlage verwenden.

## Fertige Figuren und Ei

- `BabyLabubu.png`: fröhlicher Grundzustand.
- `BabyLabubu-hungry.png`, `BabyLabubu-tired.png`, `BabyLabubu-sad.png`, `BabyLabubu-sleeping.png`: passende Stimmungen, jeweils gleicher Bildausschnitt.
- `EggClosed.png`: heiles flauschiges Ei. Risse und Aufbrechen erzeugt die App. Die drei auswählbaren Eifarben entstehen aus dieser Grafik per Farbfilter.

Die sechs Bilder sind transparente PNGs mit 1122 × 1402 Pixeln. Die Figur wird für das Baby kleiner dargestellt und wächst mit demselben Bild; dafür sind keine zusätzlichen Figurenbilder nötig. Die Kauanimation wechselt zwischen fröhlichem und offenem Mund.

## Neues Grafikpaket

| Datei | Verwendung |
|---|---|
| `Nest.png` | Leeres weiches Nest, 2172 × 724 Pixel |
| `BabyDiaper.png` | Weiße Stoffwindel mit mintfarbenem Bund/Herz, 1774 × 887 Pixel |
| `Outfit-mintVest.png` | Mintfarbene Strickweste |
| `Outfit-roseVest.png` | Rosa Strickweste, gleiche Grundform |
| `Outfit-scarf.png` | Pfirsichfarbener Strickschal |
| `Outfit-bowtie.png` | Violette Fliege |
| `Outfit-bow.png` | Rosa Haarschleife |
| `Outfit-glasses.png` | Braune Brille mit durchsichtigen Gläsern |

Alle acht Dateien haben echte Transparenz. Die sechs Kleidungs-PNGs haben 1254 × 1254 Pixel. Bei der Brille bleiben die Gläser transparent; schwarze Flächen in manchen Vorschauen sind der transparente Hintergrund.

`OutfitLayer.swift` lädt `Outfit-<item.id>.png` und setzt Position/Größe im bestehenden 300 × 380-Raster. `Wardrobe.swift` zeigt dieselben PNGs als Auswahlbild. Fehlt eine Grafik, bleibt die gezeichnete bzw. Emoji-Version nutzbar. `BabyDiaper.swift` berücksichtigt das Seitenverhältnis und lässt die Windel mit dem Wachstum verblassen. `EggScene.swift` lädt das Nest mit unverzerrtem Seitenverhältnis.

## App-Icon

`App/Assets.xcassets/AppIcon.appiconset/AppIcon.png`: 1024 × 1024 Pixel, deckender Hintergrund, keine vorab gerundeten Ecken. Xcode erzeugt die nötigen Gerätevarianten daraus. Prompt: `tools/app-icon-prompt.json`.

## Prompts und Erzeugung

- `tools/character-prompts.json`: Prompts für Ei und Figurenstimmungen.
- `tools/graphics-prompts.json`: genaue Prompts für die acht neuen PNGs; die rosa Weste verwendet zusätzlich die mintfarbene Weste als Formreferenz.
- Erzeugt mit dem eingebauten **Imagegen**-Tool. Keine API-Schlüssel erforderlich.
- Bei neuen Assets immer das freigegebene `BabyLabubu.png` als Stilreferenz mitgeben. Einzelne Gegenstände ohne Figur, Text, Bodenschatten oder Stickerkontur erzeugen lassen.
- Die Originaldateien sind hier im Repo vorhanden; Claude Code kann sie ohne Bild-KI einbinden, skalieren und die Positionen justieren.

## Bewusst verbleibende Platzhalter

Elf optionale Accessoires verwenden weiterhin Emojis: Blume, Luftballon, Sonnenblume, Kappe, Sonnenbrille, Lutscher, Schmetterling, Zylinder, Teddy, Zauberstab und Krone. Das vollständige Spiel funktioniert damit. Weitere Fellfarben oder gleichzeitige Pflege mehrerer Labubus benötigen bei einer späteren Erweiterung eventuell zusätzliche Motive.
