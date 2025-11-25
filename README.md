# Labubu iPad App Skeleton

Grundstruktur für ein SwiftUI-basiertes "Art Tamagotchi"-Spiel, ausgelegt auf iPad-only. Das Projekt ist als Swift Package organisiert und kann in ein Xcode-App-Projekt importiert oder dort als separates Modul verwendet werden.

## Zielplattform: iPadOS
- `Package.swift` setzt das Deployment Target auf iOS 17+, wodurch SwiftUI-Features wie das neue Preview-System verfügbar sind.
- Sobald du ein Xcode-App-Projekt erzeugst, stelle unter *Build Settings → Deployment Info* `iPad` als einzige Gerätefamilie ein (`UIDeviceFamily = 2`).
- Optionale Schritte für iPad-Erlebnis: Multitasking erlauben/deaktivieren, Pointer-Interaktionen, größere Schriftgrößen.

## Struktur
```
Sources/LabubuApp/
├── LabubuApp.swift        // @main Entry Point
├── Models/
│   └── LabubuState.swift  // Zustand des Eis / Labubu
├── ViewModels/
│   └── LabubuViewModel.swift
├── Views/
│   └── EggView.swift      // Einstiegsszene mit Animation
└── Resources/
    └── README.md          // Hinweise für Assets
```

## Nächste Schritte
1. Eigene Assets in `Resources` oder ein `Assets.xcassets` hinzufügen.
2. Weitere Views (Mini-Games, Aufgabenlisten) ergänzen und per Navigation aus `EggView` erreichbar machen.
3. Game-Logic erweitern: Wärmesystem, Pflegeaufgaben, Timer, Rewards.
4. Xcode-App-Projekt erstellen (`File > New > Project > App`) und dieses Package als lokale Abhängigkeit einbinden.
