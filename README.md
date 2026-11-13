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

Oben rechts in der Ecke **3 Sekunden gedrückt halten** öffnet den Eltern-Bereich:

- **Bedürfnisse leeren (zum Testen):** macht Labubu sofort hungrig, müde und traurig, um die Pflege auszuprobieren.
- **10 Sterne geben (zum Testen):** um den Kleiderschrank auszuprobieren.
- **Spiel zurücksetzen:** neues Ei, aller Fortschritt weg.

## So funktioniert die Pflege

| Bedürfnis | Blase | Leer nach | So hilft man |
|---|---|---|---|
| Hunger | 🍓 | ~6 Stunden | Essen vom Teller antippen oder zu Labubu ziehen |
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

## Grafiken

Ohne Bilddateien zeigt die App gezeichnete Platzhalter, sie ist also schon voll spielbar. Wie die KI-Grafiken entstehen und welche Dateien erwartet werden, steht in [docs/GRAFIK.md](docs/GRAFIK.md).

## Konzept & Fahrplan

Zielgruppe, Spielidee und Wochenplan bis Weihnachten: [docs/KONZEPT.md](docs/KONZEPT.md).

## Stand

- ✅ Woche 1: kindgerechte Ei-Phase, Schlüpf-Animation, Töne, Spielstand speichern
- ✅ Woche 2: Labubus Zimmer, Bedürfnisse mit Zeitverfall, Füttern, Streicheln, Schlafen, Stimmungs-Gesichter
- ⏳ Grafik-Stil festlegen (KI-Referenzbild, siehe docs/GRAFIK.md)
- ✅ Woche 3: Sterne verdienen, Kleiderschrank mit 14 Teilen, Anziehen per Tippen oder Ziehen
- ⏭ Woche 4: Sammeln (Album, Sticker, weitere Eier/Labubus)
