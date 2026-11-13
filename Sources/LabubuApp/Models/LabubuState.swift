import Foundation

enum HatchStage: String, Codable {
    /// Ei liegt da und wird angetippt.
    case egg
    /// Genug getippt – die Schlüpf-Animation läuft (oder wurde unterbrochen und läuft beim nächsten Start erneut).
    case hatching
    /// Labubu ist geschlüpft.
    case hatched
}

/// Gesamter Spielstand. Wird als JSON gespeichert, daher nur einfache, Codable-Felder.
struct LabubuState: Codable, Equatable {
    /// So oft muss das Kind tippen, bis Labubu schlüpft. Jeder Tipp zählt – auch ganz schnelles Tippen.
    static let tapsToHatch = 18
    /// Anzahl der Herzen in der Fortschrittsanzeige.
    static let progressHearts = 6
    /// Anzahl sichtbarer Riss-Stufen auf dem Ei.
    static let crackLevels = 3

    private(set) var eggTaps: Int = 0
    private(set) var hatchedAt: Date?

    var stage: HatchStage {
        if hatchedAt != nil { return .hatched }
        return eggTaps >= Self.tapsToHatch ? .hatching : .egg
    }

    /// 0…1
    var hatchProgress: Double {
        min(1, Double(eggTaps) / Double(Self.tapsToHatch))
    }

    /// Wie viele Herzen gefüllt sind (0…progressHearts).
    var filledHearts: Int {
        Int(hatchProgress * Double(Self.progressHearts))
    }

    /// 0 = heil, 1…crackLevels = immer mehr Risse. Der erste Riss erscheint nach einem Viertel der Tipps.
    var crackLevel: Int {
        min(Self.crackLevels, Int(hatchProgress * Double(Self.crackLevels + 1)))
    }

    mutating func tapEgg() {
        guard stage == .egg else { return }
        eggTaps += 1
    }

    mutating func finishHatching(at date: Date = Date()) {
        guard stage == .hatching else { return }
        hatchedAt = date
    }
}
