# Labubu iPad App

SwiftUI-basiertes "Art Tamagotchi"-Spiel, nur für iPad (iOS 17+). Man wärmt und pflegt ein Ei, bis ein Baby-Labubu schlüpft.

## Starten

Das Xcode-Projekt wird mit [XcodeGen](https://github.com/yonaskolb/XcodeGen) aus `project.yml` erzeugt. Nach Änderungen an `project.yml`:

```bash
xcodegen generate
```

Dann `Labubu.xcodeproj` öffnen, Schema **LabubuGame** und einen iPad-Simulator wählen, ⌘R.

Für ein echtes iPad: im Target *LabubuGame → Signing & Capabilities* das eigene Team wählen und ggf. die Bundle-ID (`com.labubu.game`) anpassen.

## Aufbau

Die App ist zweigeteilt:

- **`App/`** – die eigentliche iOS-App (nur der `@main`-Einstieg).
- **`Sources/LabubuApp/`** – Swift Package mit der gesamten Spiellogik und allen Views. Die App bindet es als lokales Package ein.

```
App/
└── LabubuGameApp.swift        // @main, zeigt LabubuRootView
Sources/LabubuApp/
├── LabubuRootView.swift       // öffentliche Einstiegs-View des Packages
├── Models/
│   ├── LabubuState.swift      // Spielstand: Ei, Schlüpfen, Pflege-Aktionen, Stimmung
│   ├── Needs.swift            // Hunger, Spaß, Energie + Zeitverfall
│   ├── Outfit.swift           // Kleiderschrank-Katalog (Teile, Plätze, Preise)
│   └── GameStore.swift        // speichert den Spielstand als JSON
├── ViewModels/
│   └── LabubuViewModel.swift
├── Audio/
│   └── SoundPlayer.swift      // kurze Effekt-Töne
├── Views/
│   ├── GameView.swift         // Hintergrund, Szenenwechsel, versteckter Eltern-Bereich
│   ├── StageLayout.swift      // gemeinsames Layout aller Szenen
│   ├── EggScene.swift         // Ei antippen + Schlüpf-Animation
│   ├── RoomScene.swift        // Labubus Zimmer: füttern, streicheln, schlafen, anziehen
│   └── Components/            // Ei, Labubu (mit Stimmungen), Kleidung, Kleiderschrank, Zimmer-Teile, Effekte
└── Resources/                 // Bilder (optional) und Töne
Tests/LabubuAppTests/          // Tests für Spiellogik, Bedürfnisse und Speichern
tools/gen_sounds.py            // erzeugt die Effekt-Töne
project.yml                    // XcodeGen-Konfiguration (iPad only)
```

Tests laufen in Xcode mit ⌘U.

## Eltern-Bereich

**Für Clara:** Der 🥚-Knopf mit dem Neustartpfeil oben rechts neben dem Lautsprecher startet sofort ein neues Ei. Sterne, gekaufte Kleidung und das Outfit bleiben erhalten. Das geht auch während des Rollens oder Schlüpfens; das neue Ei liegt wieder im Nest. Der vollständige Reset im Eltern-Bereich löscht dagegen weiterhin alles.

Oben rechts den **Lautsprecher 3 Sekunden gedrückt halten** öffnet den Eltern-Bereich. Kurzes Antippen schaltet Musik und Geräusche gemeinsam stumm bzw. wieder an. Der Zustand wird gespeichert; die getrennten Einstellungen bleiben erhalten.

- **Bedürfnisse leeren (zum Testen):** macht Labubu sofort hungrig, müde und traurig, um die Pflege auszuprobieren.
- **10 Sterne geben (zum Testen):** um den Kleiderschrank auszuprobieren.
- **Musik / Geräusche ein- oder ausschalten:** getrennte, gespeicherte Einstellungen.
- **Spiel zurücksetzen:** neues Ei, aller Fortschritt weg.

## So funktioniert die Pflege

| Bedürfnis | Blase | Leer nach | So hilft man |
|---|---|---|---|
| Hunger | 🍓 | ~6 Stunden | Essen vom Teller direkt in den Mund ziehen |
| Spaß | 💖 | ~4 Stunden | Labubu antippen (kitzeln) oder drüberwischen (streicheln) |
| Energie | 🌙 | ~10 Stunden | Licht aus 💡 – im Dunkeln schläft Labubu und ist nach ~30 Sekunden ausgeschlafen |

## Sterne & Kleiderschrank

Sterne ⭐ gibt es fürs Kümmern – aber nur, wenn Labubu es auch braucht (Dauer-Tippen bringt nichts):

| Wofür | Sterne |
|---|---|
| Schlüpfen (Startguthaben) | 3 |
| Jedes Essen, das Labubu annimmt | 1 |
| Alle 4× Streicheln/Kitzeln, solange Labubu nicht ganz fröhlich ist | 1 |
| Müde ins Bett und ausgeschlafen wieder aufgeweckt | 2 |

Im Kleiderschrank 👗 gibt es 14 Teile für Kopf, Augen, Hals und Hand. 🎀 und 👓 sind gratis, der Rest kostet 1–5 Sterne. Der Preis steht als kleine Sterne unter dem Teil (zum Abzählen), Teile, die man sich leisten kann, haben einen gelben Rahmen und wippen. Antippen oder auf Labubu ziehen zieht an, nochmal antippen zieht aus. Pro Platz passt ein Teil.

Die Zeit läuft auch weiter, wenn die App zu ist. Ist ein Bedürfnis fast leer, pulsiert seine Blase und Labubu zeigt es im Gesicht und in einer Denkblase. Leer hat keine Folgen außer einem traurigen Gesicht.

## Ei rollen, Füttern und Spielen

- **Auswahl und Baby:** Zu Beginn stehen drei Eier (Beige, Rosa, Mint) zur Auswahl. Clara wählt eines aus und legt es damit ins Nest. Das geschlüpfte Baby startet bei 60 % der vollen Größe und trägt eine weiße/mintfarbene Windel. Kleidung und Mund-Trefferzone passen sich an die tatsächliche Größe an.
- **Wachstum:** Eine angenommene Mahlzeit bringt 5 Prozentpunkte Wachstum; wirklich zurückgewonnene Schlafenergie bringt anteilig bis zu 15 Prozentpunkte pro voller Energieladung. Das funktioniert auch nach einer Offline-Schlafphase. Wiederholtes Umschalten des Lichts ohne Erholung zählt nicht. Bei 30–40 % Wachstum verblasst die Windel; bei 100 % ist die volle Größe erreicht. Ein neues Ei setzt Wachstum und Auswahl zurück, die Sammlung bleibt erhalten.
- **Ei:** Beim Öffnen wird die iPad-Haltung als Ausgangspunkt genommen. Bewegen/Kippen lässt das Ei rollen, ruhiges Halten bremst es in jeder Haltung ab. Die Spielfläche hat Ränder. Das Nest hält kleine Bewegungen aus; nach dem Herausrollen muss das Ei ins Nest zurückgezogen werden, bevor Antippen oder kurze Streichelbewegungen wieder wärmen. Das Nest wird dann mintfarben. Beim Schlüpfen stoppt der Sensor und das Ei sitzt mittig. Im Hintergrund ist der Sensor aus; im Simulator funktioniert Ziehen auch ohne Sensor.
- **Füttern:** Futter zum Mund ziehen, der während des Ziehens markiert wird. Auf Kopf oder Bauch abgelegtes Essen springt zurück. Erfolgreiches Füttern zeigt fünf schnelle Kaubewegungen und einen selbst synthetisierten „Hap, hap, hap, hap, hap“-Laut. Währenddessen kann kein weiteres Essen angenommen werden. VoiceOver bietet alternativ die Aktion „Füttern“.
- **Spielen:** 🏀 startet eine kurze Hüpf-/Tanzrunde. Sie steigert Spaß und verbraucht 18 Prozentpunkte Energie sowie etwas Sättigung. Nach ungefähr vier Runden ist Labubu müde; unter 20 % Energie zeigt es Schlafsymbole statt weiterzuspielen. Licht aus lässt es wie bisher schlafen und Energie tanken. Es gibt keine Strafe.
- **Ton erzeugen:** `python3 tools/gen_hap.py Sources/LabubuApp/Resources/hap.wav` benötigt nur die Python-Standardbibliothek.

Die Tests umfassen Rollgrenzen, Abbremsen, Nest-Drops, Mund-Trefferzonen und den Spielen-Schlafen-Kreislauf. `LabubuGameUITests` prüft zusätzlich die Touch-Gesten im Simulator; dieser UI-Test setzt dort den Spielstand zurück und überspringt sich auf echten Geräten.

## Musik und passende Kleidung

Eine eigene, 24 Sekunden lange Spieluhr-Schleife läuft leise im Hintergrund, im Schlaf langsamer und leiser. Beim Verlassen der App pausiert sie. Erzeugen: `python3 tools/gen_music.py Sources/LabubuApp/Resources/musicbox.wav` (nur Python-Standardbibliothek). Die vorhandenen Effekte bleiben erhalten, mit reduzierter Lautstärke.

Zusätzlich zu den 14 ursprünglichen Teilen gibt es eine Fliege und zwei gezeichnete Westen (Mint/Rosa). Westen belegen einen eigenen Körper-Platz und lassen sich mit Hals-Accessoires kombinieren. Der Schal sitzt bei Verwendung unserer Labubu-Grafik am Hals. Der Kleiderschrank hat zwei seitlich scrollbar angeordnete Reihen.

## Grafiken

Ohne Bilddateien zeigt die App gezeichnete Platzhalter, sie ist also schon voll spielbar. Wie die KI-Grafiken entstehen und welche Dateien erwartet werden, steht in [docs/GRAFIK.md](docs/GRAFIK.md).

## Konzept & Fahrplan

Zielgruppe, Spielidee und Wochenplan bis Weihnachten: [docs/KONZEPT.md](docs/KONZEPT.md).

## Stand

- ✅ Woche 1: kindgerechte Ei-Phase, Schlüpf-Animation, Töne, Spielstand speichern
- ✅ Woche 2: Labubus Zimmer, Bedürfnisse mit Zeitverfall, Füttern, Streicheln, Schlafen, Stimmungs-Gesichter
- ✅ Grafik-Stil und Bilder: Figur/Stimmungen, Ei, App-Icon, Nest, Windel und sechs Kleidungs-PNGs (siehe docs/GRAFIK.md)
- ✅ Woche 3: Sterne verdienen, Kleiderschrank mit 14 Teilen, Anziehen per Tippen oder Ziehen
- ⏭ Woche 4: Sammeln (Album, Sticker, weitere Eier/Labubus)

## Übergabe

Für die Weiterarbeit mit Claude Code: [docs/HANDOFF.md](docs/HANDOFF.md). Der aktuelle Stand wird auf GitHub unter `main` veröffentlicht. Der lokale Entwicklungs-Worktree verwendet den Branch `claude/labubu-app-overview-812111`; der separate lokale Hauptcheckout kann noch einen älteren Stand enthalten.
