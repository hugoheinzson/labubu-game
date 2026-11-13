# Übergabe an Claude Code

Stand: 13.11.2026. Die App ist ein privates iPad-Spiel für Clara. Sie soll ohne Lesen bedienbar sein, große Antippflächen haben und keine Strafen enthalten. Konzept und Fahrplan stehen in [KONZEPT.md](KONZEPT.md), die Bedienung in [README.md](../README.md).

## Hier weiterarbeiten

- Aktiver Entwicklungsbranch: `claude/labubu-app-overview-812111`.
- Zugehöriger Worktree, relativ zum Hauptcheckout: `.claude/worktrees/labubu-app-overview-812111`.
- `main` enthält weiterhin das alte Grundgerüst. Im Hauptcheckout liegen zusätzlich separate, nicht committete Änderungen des Nutzers und Grafikdateien. Nicht ungeprüft zurücksetzen, überschreiben oder mit diesem Worktree vermischen. Vor weiterer Arbeit `git worktree list`, `git status --short` und den aktuellen Branch prüfen.
- Die lauffähige App liegt als `Labubu.xcodeproj` im Entwicklungsworktree. Ihre Spiellogik kommt aus dem lokalen Swift Package unter `Sources/LabubuApp/`. `project.yml` ist die Quelle für XcodeGen; nach Projektstruktur-Änderungen das Projekt neu erzeugen.

## Umgesetztes Verhalten

- **Drei Start-Eier:** Beige, Rosa und Mint stehen zur Auswahl. Clara wählt eines aus und pflegt anschließend dieses eine Baby. Es gibt derzeit keine gleichzeitige Pflege mehrerer Labubus. Die drei Eier haben dieselben Spielregeln; die bestätigte braune Labubu-Figur bleibt erhalten.
- **Ei und Nest:** CoreMotion steuert das Rollen. Die Haltung beim Öffnen dient als Ausgangspunkt. Nur während tatsächlicher Bewegung wirkt die Neigung als Antrieb; ruhiges Halten bremst auch ein schräg gehaltenes iPad ab. Kleine Bewegungen hält das Nest aus. Außerhalb des Nests gibt es keine Wärme-Punkte. Das Ei lässt sich zurückziehen, auch direkt auf die sichtbare Nestschale. Tippen und kurze Streichelbewegungen im Nest wärmen es. Ränder halten es auf der Fläche; beim Schlüpfen und im Hintergrund stoppt der Sensor. Im Simulator kann man das Ei ohne Sensor ziehen.
- **Baby und Wachstum:** Ein frisch geschlüpftes Baby startet bei 60 % Größe und mit Windel. `growthProgress` reicht von 0 bis 1, `growthScale` von 0,60 bis 1. Eine angenommene Mahlzeit gibt 0,05 Wachstum. Schlaf gibt anteilig 0,15 pro tatsächlich zurückgewonnener voller Energieladung. Offline-Schlaf wird berücksichtigt. Derselbe Zeitraum wird nicht doppelt gezählt; bloßes Licht-Umschalten erzeugt kein Wachstum. Die Windel verblasst zwischen 30 und 40 % Wachstum. Figur, Kleidung und Mund-Trefferzone folgen gemeinsam der Babygröße.
- **Füttern:** Essen muss in die Mundzone gezogen werden; diese wird beim Ziehen markiert. Kopf und Bauch zählen nicht. Falsche Drops federn zurück. Nach erfolgreichem Füttern folgen fünf schnelle Kaubewegungen und der synthetisierte „Hap, hap, hap, hap, hap“-Laut. Währenddessen sind weiteres Füttern und die Spielaktion gesperrt. Für VoiceOver gibt es die alternative Aktion „Füttern“.
- **Spielen und Schlafen:** 🏀 startet eine kurze Hüpf-/Tanzrunde. Sie erhöht Spaß, verbraucht 18 Prozentpunkte Energie und etwas Sättigung. Unter 20 % Energie wird keine weitere Runde gestartet; Labubu zeigt Schlafsymbole. Licht aus lässt Energie wie bisher in ungefähr 30 Sekunden nachfüllen. Labubu stirbt nicht und verliert keine Sammlung.
- **Claras Neustart:** Oben rechts neben dem Lautsprecher startet 🥚 mit Neustartpfeil sofort eine neue Eierauswahl. Sterne, gekaufte Kleidung und getragenes Outfit bleiben erhalten. Ei-Auswahl, Wärme und Wachstum werden zurückgesetzt. Eine neue Szenen-ID verhindert, dass altes Rollen oder eine abgebrochene Schlüpfanimation fortgesetzt wird. Der vollständige Eltern-Reset löscht weiterhin alles.
- **Ton und Musik:** Kurzes Tippen auf den Lautsprecher schaltet alle App-Töne stumm bzw. wieder an. Drei Sekunden Halten öffnet den Elternbereich. Dort sind Musik und Geräusche zusätzlich getrennt schaltbar. Einstellungen werden gespeichert. Die leise Spieluhr-Schleife dauert 24 Sekunden, wird im Schlaf langsamer/leiser und pausiert beim Verlassen der App. Die WAV-Generatoren benötigen nur die Python-Standardbibliothek: `tools/gen_sounds.py`, `tools/gen_hap.py`, `tools/gen_music.py`.
- **Sammlung und Kleidung:** Woche 3 mit Sternen, Kaufen, Anziehen/Ausziehen und seitlich scrollbarem Kleiderschrank bleibt enthalten. Es gibt 17 Teile, einschließlich Fliege und zwei Westen mit eigenem Körper-Slot. Ein Körperteil lässt sich mit Hals-Accessoires kombinieren.
- **App-Icon:** Das Labubu-Icon ist im Asset-Katalog unter `App/Assets.xcassets/AppIcon.appiconset/` eingebunden.

## Grafiken und Referenzen

Die vom Nutzer freigegebene Masterfigur ist `Sources/LabubuApp/Resources/BabyLabubu.png`. Identität, braunes Plüschfell und Gesicht davon beibehalten. Die vorhandenen Stimmungen sind `BabyLabubu-hungry.png`, `BabyLabubu-tired.png`, `BabyLabubu-sad.png` und `BabyLabubu-sleeping.png`; das heile Ei heißt `EggClosed.png`. Risse und Schlüpfen zeichnet die App darüber. Stimmungswechsel dürfen die Figur nicht versetzen.

Das zusätzliche Grafikpaket dieser Übergabe umfasst folgende transparente PNGs in `Sources/LabubuApp/Resources/`:

| Datei | Verwendung |
|---|---|
| `Nest.png` | Nest auf der Ei-Spielfläche |
| `BabyDiaper.png` | Windel als Overlay für die kleine Baby-Figur |
| `Outfit-mintVest.png` | Mintfarbene Weste |
| `Outfit-roseVest.png` | Rosafarbene Weste |
| `Outfit-scarf.png` | Schal |
| `Outfit-bowtie.png` | Fliege |
| `Outfit-bow.png` | Kopfschleife |
| `Outfit-glasses.png` | Brille |

Die Integration verwendet PNGs, sofern vorhanden, und behält gezeichnete bzw. Emoji-Fallbacks. Nach der Generierung Transparenz, Ausrichtung und die Passform am kleinen wie am großen Labubu kontrollieren. Die restlichen elf Kleidungsstücke sind weiterhin Emoji-Platzhalter.

Die Prompts dieses zusätzlichen Pakets sind in `tools/graphics-prompts.json` dokumentiert. Die ursprünglichen Figuren-/Ei-Prompts liegen in `tools/character-prompts.json`. Der Icon-Prompt liegt in `tools/app-icon-prompt.json`. Weitere ursprüngliche Vorgaben stehen in [GRAFIK.md](GRAFIK.md).

## Validierung und Installation

Der vollständige Stand **einschließlich aller acht zusätzlichen PNGs** hat **43 erfolgreiche Tests: 42 Modell-/Unit-Tests und einen UI-Test**. Der signierte Gerätebuild ist erfolgreich und wurde auf dem angeschlossenen physischen iPad installiert. Der lokale Ergebnisbericht liegt unter `/tmp/labubu-graphics-final.xcresult`; exportierte Test-Screenshots unter `/tmp/labubu-graphics-final-attachments/`. Diese temporären Berichte sind nicht Teil des Git-Commits.

Aus dem Entwicklungsworktree:

```sh
xcodegen generate
xcrun simctl list devices available
```

Eine verfügbare iPad-Simulator-ID aus der Liste wählen, anschließend beispielsweise:

```sh
LABUBU_SIMULATOR_UDID="<Simulator-ID>"
xcodebuild -project Labubu.xcodeproj -scheme LabubuGame \
  -destination "platform=iOS Simulator,id=$LABUBU_SIMULATOR_UDID" \
  -derivedDataPath /tmp/labubu-handoff-build \
  test CODE_SIGNING_ALLOWED=NO
```

`LabubuGameUITests` setzt während des Ablauftests den **Simulator-Spielstand** zurück. Vorhandene manuelle Simulator-Spielstände bei Bedarf vorher sichern. Der UI-Test besitzt eine explizite Simulator-Prüfung und überspringt sich auf physischen Geräten. Er prüft Auswahl, Herausziehen und Zurücksetzen des Eis, die Wärme-Sperre außerhalb des Nests, Schlüpfen, falsche/richtige Futter-Drops, Spielen, Schlafen, Laden und Claras Neustart. Die anderen Tests decken Persistenz, Bedürfnisse, Sterne, Kleidung, Wachstum, Offline-Schlaf und Rollphysik ab.

Für das echte iPad zunächst `xcrun devicectl list devices` ausführen. Entwicklerteam und Zielgerät aus der lokalen Xcode-Einrichtung übernehmen; keine persönlichen Team- oder Geräte-IDs ins Repository schreiben. Ein signierter Gerätebuild kann so erstellt werden:

```sh
LABUBU_DEVICE_ID="<Geräte-ID>"
LABUBU_TEAM_ID="<eigenes Entwicklerteam>"
xcodebuild -project Labubu.xcodeproj -scheme LabubuGame -configuration Debug \
  -destination "id=$LABUBU_DEVICE_ID" \
  -derivedDataPath /tmp/labubu-device-build \
  -allowProvisioningUpdates DEVELOPMENT_TEAM="$LABUBU_TEAM_ID" \
  CODE_SIGN_STYLE=Automatic build
xcrun devicectl device install app --device "$LABUBU_DEVICE_ID" \
  /tmp/labubu-device-build/Build/Products/Debug-iphoneos/LabubuGame.app
xcrun devicectl device process launch --device "$LABUBU_DEVICE_ID" com.labubu.game
```

Auf einem gesperrten iPad kann die Installation erfolgreich sein, während der automatische Start abgelehnt wird. Dann entsperren und die App vom Home-Bildschirm öffnen. Für eine normale Aktualisierung keinen Spielstand auf dem echten Gerät zurücksetzen.

### Abschluss des Grafikpakets

- Acht neue PNGs erzeugt, Transparenz und Abmessungen geprüft; Dateien und exakte Prompts liegen im Repo.
- Nest, Windel und sechs Kleidungsstücke bevorzugen die neuen PNGs, mit bisherigen Fallbacks. Die Windel ist für ihren sichtbaren Rand auf die Baby-Hüfte kalibriert; die Kleidungs-PNGs nutzen das bestehende Platzierungsraster und wachsen mit der Figur. Weitere Feinabstimmung beim Anziehen kann direkt im Code erfolgen.
- Baby/Windel und Eierauswahl im Simulator visuell kontrolliert; der komplette Touch-Ablauf mit Füttern, Spielen, Schlafen und Neustart ist erfolgreich.
- `git diff --check` erfolgreich. Der gesamte Übergabestand wird im aktiven Entwicklungsbranch committed; die genaue Commit-ID liefert `git log -1 --oneline`.

## Offene Punkte für die Weiterarbeit

- Der Nutzer fand die „Fensterdarstellung“ unpassend. Ob das gezeichnete Zimmerfenster oder die Darstellung der gesamten App auf dem iPad gemeint ist, wurde noch nicht geklärt. Nicht auf Verdacht umbauen.
- Drei Eier zur Auswahl ist die bisher verwendete Auslegung. Eine gleichzeitige Mehr-Labubu-Pflege wurde nicht bestätigt und ist nicht implementiert.
- Die tatsächliche Neigungsrichtung, Empfindlichkeit und das Abbremsen müssen noch durch Bewegen des echten iPads mit der Hand beurteilt werden. Simulator- und Modelltests ersetzen diesen physischen Test nicht.
- Die elf verbleibenden Emoji-Kleidungsstücke können später nach demselben Referenzstil ersetzt werden.
- Das Projekt nennt iOS 17 als Deployment-Ziel. Es nutzt unter anderem SwiftUIs `onGeometryChange`; die echte Mindestversion und die Verfügbarkeit weiterer APIs bei Änderungen mit dem eingesetzten Apple-Toolchain/SDK prüfen. Bisher wurde mit dem hier vorhandenen aktuellen Xcode und den verfügbaren iPad-Laufzeiten gebaut.
- Die weiteren Inhalte von Woche 4 und danach (Album, zusätzliche Sammlungen, weitere Minispiele) bleiben im Konzept vermerkt und wurden durch diese Erweiterungen nicht vollständig umgesetzt.
