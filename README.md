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
└── LabubuGameApp.swift      // @main, zeigt LabubuRootView
Sources/LabubuApp/
├── LabubuRootView.swift     // öffentliche Einstiegs-View des Packages
├── Models/
│   └── LabubuState.swift    // Zustand: Wärme, Pflege, Phase (Ei → Wärmen → Geschlüpft)
├── ViewModels/
│   └── LabubuViewModel.swift
├── Views/
│   └── EggView.swift        // Ei-Szene mit Wackel-Animation + Baby-Labubu-Endzustand
└── Resources/
    └── README.md            // welche Bilder erwartet werden
project.yml                  // XcodeGen-Konfiguration (iPad only)
```

## Grafiken

Die App erwartet `EggClosed.png`, `EggIncubating.png` und `BabyLabubu.png` in `Sources/LabubuApp/Resources/` (Details dort im README). Fehlt ein Bild, zeigt sie ein SF-Symbol als Platzhalter – die App bleibt also spielbar.

## Nächste Schritte

1. Echte Grafiken erstellen und ablegen.
2. Spielstand speichern (aktuell beginnt jeder Start wieder beim kalten Ei).
3. Pflege nach dem Schlüpfen: Bedürfnisse (Hunger, Laune, Müdigkeit), Füttern, Streicheln.
4. Mini-Games, Belohnungen/Sticker.
