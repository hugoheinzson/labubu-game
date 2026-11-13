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

    // Pflege (ab dem Schlüpfen)
    private(set) var needs = Needs.newborn
    /// Zeitpunkt, bis zu dem `needs` fortgeschrieben ist.
    private(set) var needsUpdatedAt: Date?
    private(set) var sleepingSince: Date?

    /// Wie viel ein Essen satt macht.
    static let mealSize = 0.25
    /// Wie viel einmal Streicheln/Kitzeln fröhlich macht.
    static let petAmount = 0.08

    init() {}

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
        needs = .newborn
        needsUpdatedAt = date
    }

    // MARK: - Pflege

    var isSleeping: Bool { sleepingSince != nil }

    var mood: LabubuMood {
        if isSleeping { return .sleeping }
        switch wish {
        case .hunger: return .hungry
        case .energy: return .tired
        case .fun: return .sad
        case nil: return .happy
        }
    }

    enum Need { case hunger, energy, fun }

    /// Das dringendste leere Bedürfnis (Reihenfolge: Hunger, Müdigkeit, Spaß) – wird als Denkblase gezeigt.
    var wish: Need? {
        if needs.hunger < Needs.lowThreshold { return .hunger }
        if needs.energy < Needs.lowThreshold { return .energy }
        if needs.fun < Needs.lowThreshold { return .fun }
        return nil
    }

    /// Schreibt die Bedürfnisse bis `now` fort – auch über Zeiten, in denen die App geschlossen war.
    mutating func advanceNeeds(to now: Date) {
        guard stage == .hatched else { return }
        let last = needsUpdatedAt ?? now
        needs.advance(by: now.timeIntervalSince(last), sleeping: isSleeping)
        needsUpdatedAt = max(last, now)
    }

    /// Gibt `false` zurück, wenn Labubu schläft oder schon satt ist (dann schüttelt es den Kopf).
    @discardableResult
    mutating func feed(at now: Date = Date()) -> Bool {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping, needs.hunger < 0.95 else { return false }
        needs.hunger += Self.mealSize
        needs.clamp()
        return true
    }

    mutating func pet(at now: Date = Date()) {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping else { return }
        needs.fun += Self.petAmount
        needs.clamp()
    }

    mutating func sleep(at now: Date = Date()) {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping else { return }
        sleepingSince = now
    }

    mutating func wakeUp(at now: Date = Date()) {
        advanceNeeds(to: now)
        sleepingSince = nil
    }

    /// Nur für den Eltern-Bereich: alle Bedürfnisse fast leer, um die Pflege auszuprobieren.
    mutating func drainNeedsForTesting(at now: Date = Date()) {
        guard stage == .hatched else { return }
        needs = Needs(hunger: 0.1, fun: 0.2, energy: 0.15)
        needsUpdatedAt = now
        sleepingSince = nil
    }
}

// Spielstände aus Woche 1 kennen die Pflege-Felder noch nicht – dann gelten die Standardwerte.
extension LabubuState {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        eggTaps = try c.decode(Int.self, forKey: .eggTaps)
        hatchedAt = try c.decodeIfPresent(Date.self, forKey: .hatchedAt)
        needs = try c.decodeIfPresent(Needs.self, forKey: .needs) ?? .newborn
        needsUpdatedAt = try c.decodeIfPresent(Date.self, forKey: .needsUpdatedAt) ?? hatchedAt
        sleepingSince = try c.decodeIfPresent(Date.self, forKey: .sleepingSince)
    }
}
