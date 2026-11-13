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
│   ├── LabubuState.swift      // Spielstand: Tipps am Ei, Risse, Schlüpfzeitpunkt
│   └── GameStore.swift        // speichert den Spielstand als JSON
├── ViewModels/
│   └── LabubuViewModel.swift
├── Audio/
│   └── SoundPlayer.swift      // kurze Effekt-Töne
├── Views/
│   ├── GameView.swift         // Hintergrund, Szenenwechsel, versteckter Eltern-Bereich
│   ├── StageLayout.swift      // gemeinsames Layout aller Szenen
│   ├── EggScene.swift         // Ei antippen + Schlüpf-Animation
│   ├── HatchedScene.swift     // Labubu ist da
│   └── Components/            // Ei, Labubu, Glitzer, Konfetti, Herzen, Bild-Lookup
└── Resources/                 // Bilder (optional) und Töne
Tests/LabubuAppTests/          // Tests für Spiellogik und Speichern
project.yml                    // XcodeGen-Konfiguration (iPad only)
```

Tests laufen in Xcode mit ⌘U.

## Eltern-Bereich

Oben rechts in der Ecke **3 Sekunden gedrückt halten** öffnet den Eltern-Bereich, um das Spiel zurückzusetzen.

## Grafiken

Ohne Bilddateien zeigt die App gezeichnete Platzhalter, sie ist also schon voll spielbar. Wie die KI-Grafiken entstehen und welche Dateien erwartet werden, steht in [docs/GRAFIK.md](docs/GRAFIK.md).

## Konzept & Fahrplan

Zielgruppe, Spielidee und Wochenplan bis Weihnachten: [docs/KONZEPT.md](docs/KONZEPT.md).

## Stand

- ✅ Woche 1: kindgerechte Ei-Phase, Schlüpf-Animation, Töne, Spielstand speichern
- ⏳ Grafik-Stil festlegen (KI-Referenzbild, siehe docs/GRAFIK.md)
- ⏭ Woche 2: Labubus Zimmer + Pflegen
