import Foundation

/// Die drei Bedürfnisse von Labubu. 1 = rundum versorgt, 0 = ganz leer.
/// Leer hat keine Strafe – Labubu schaut dann nur hungrig, müde oder traurig.
struct Needs: Codable, Equatable {
    var hunger: Double   // 1 = satt
    var fun: Double      // 1 = fröhlich
    var energy: Double   // 1 = ausgeschlafen

    /// Frisch geschlüpft: ausgeschlafen und fröhlich, aber hungrig – die erste Aufgabe ist also Füttern.
    static let newborn = Needs(hunger: 0.3, fun: 0.9, energy: 0.9)

    /// Ab hier gilt ein Bedürfnis als „leer“ und Labubu zeigt es.
    static let lowThreshold = 0.35

    /// In dieser Zeit sinkt ein Bedürfnis von voll auf leer (Labubu ist wach).
    static let hungerEmptyAfter: TimeInterval = 6 * 3600
    static let funEmptyAfter: TimeInterval = 4 * 3600
    static let energyEmptyAfter: TimeInterval = 10 * 3600
    /// Im Schlaf füllt sich die Energie in dieser Zeit von leer auf voll – kurz, damit es für ein Kind spürbar ist.
    static let sleepRefillDuration: TimeInterval = 30
    /// Im Schlaf sinken Hunger und Spaß nur mit diesem Faktor.
    static let sleepDecayFactor = 0.3

    mutating func advance(by seconds: TimeInterval, sleeping: Bool) {
        guard seconds > 0 else { return }
        let decay = sleeping ? Self.sleepDecayFactor : 1
        hunger -= seconds / Self.hungerEmptyAfter * decay
        fun -= seconds / Self.funEmptyAfter * decay
        if sleeping {
            energy += seconds / Self.sleepRefillDuration
        } else {
            energy -= seconds / Self.energyEmptyAfter
        }
        clamp()
    }

    mutating func clamp() {
        hunger = min(1, max(0, hunger))
        fun = min(1, max(0, fun))
        energy = min(1, max(0, energy))
    }
}

enum LabubuMood: String, CaseIterable {
    case happy, hungry, tired, sad, sleeping
}
