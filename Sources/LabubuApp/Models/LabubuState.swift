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
    private enum CodingKeys: String, CodingKey {
        case eggTaps, hatchedAt, chosenEgg, growthProgress
        case needs, needsUpdatedAt, sleepingSince
        case stars, ownedItems, worn, petsTowardStar, sleepRewardPending
    }

    /// So oft muss das Kind tippen, bis Labubu schlüpft. Jeder Tipp zählt – auch ganz schnelles Tippen.
    static let tapsToHatch = 18
    /// Anzahl der Herzen in der Fortschrittsanzeige.
    static let progressHearts = 6
    /// Anzahl sichtbarer Riss-Stufen auf dem Ei.
    static let crackLevels = 3

    private(set) var eggTaps: Int = 0
    private(set) var hatchedAt: Date?
    /// nil = vor dem ersten Wärmen eines von drei Eiern auswählen.
    private(set) var chosenEgg: EggVariant?
    /// Dauerhafter Pflegefortschritt: 0 = kleines Baby, 1 = ausgewachsen.
    private(set) var growthProgress: Double = 0

    var growthScale: Double { 0.6 + growthProgress * 0.4 }
    var isBaby: Bool { growthProgress < 0.4 }

    static let growthPerMeal = 0.05
    static let growthPerRecoveredEnergy = 0.15

    // Pflege (ab dem Schlüpfen)
    private(set) var needs = Needs.newborn
    /// Zeitpunkt, bis zu dem `needs` fortgeschrieben ist.
    private(set) var needsUpdatedAt: Date?
    private(set) var sleepingSince: Date?

    // Sterne & Kleiderschrank
    private(set) var stars: Int = 0
    private(set) var ownedItems: Set<String> = OutfitItem.freeItemIDs
    /// Getragene Teile: Slot (rawValue) → Item-ID. String-Schlüssel, damit das JSON lesbar bleibt.
    private(set) var worn: [String: String] = [:]
    /// Zählt Streicheleinheiten bis zum nächsten Stern.
    private(set) var petsTowardStar: Int = 0
    /// Labubu ging müde ins Bett – nach dem Ausschlafen gibt es Sterne.
    private(set) var sleepRewardPending = false

    /// Startguthaben nach dem Schlüpfen, damit gleich etwas freigeschaltet werden kann.
    static let hatchBonusStars = 3
    static let starsPerMeal = 1
    static let petsPerStar = 4
    static let starsPerGoodSleep = 2

    /// Wie viel ein Essen satt macht.
    static let mealSize = 0.25
    /// Wie viel einmal Streicheln/Kitzeln fröhlich macht.
    static let petAmount = 0.08

    init() {}

    /// Clara darf ein neues Ei starten, ohne ihre gesammelten Sachen zu verlieren.
    mutating func startNewEgg() {
        let savedStars = stars, savedItems = ownedItems, savedOutfit = worn
        self = LabubuState()
        stars = savedStars
        ownedItems = savedItems
        worn = savedOutfit
    }

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
        // Direkte Modell-Aufrufer und ältere Spielstände bleiben kompatibel.
        if chosenEgg == nil { chosenEgg = .classic }
        eggTaps += 1
    }

    mutating func selectEgg(_ variant: EggVariant) {
        guard stage == .egg, eggTaps == 0 else { return }
        chosenEgg = variant
    }

    mutating func finishHatching(at date: Date = Date()) {
        guard stage == .hatching else { return }
        hatchedAt = date
        needs = .newborn
        needsUpdatedAt = date
        stars += Self.hatchBonusStars
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
        let energyBefore = needs.energy
        needs.advance(by: now.timeIntervalSince(last), sleeping: isSleeping)
        if isSleeping {
            // Nur wirklich zurückgewonnene Energie zählt: Schalter-Tippen bringt nichts.
            grow(by: max(0, needs.energy - energyBefore) * Self.growthPerRecoveredEnergy)
        }
        needsUpdatedAt = max(last, now)
    }

    /// Gibt `false` zurück, wenn Labubu schläft oder schon satt ist (dann schüttelt es den Kopf).
    @discardableResult
    mutating func feed(at now: Date = Date()) -> Bool {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping, needs.hunger < 0.95 else { return false }
        needs.hunger += Self.mealSize
        needs.clamp()
        stars += Self.starsPerMeal
        grow(by: Self.growthPerMeal)
        return true
    }

    private mutating func grow(by amount: Double) {
        growthProgress = min(1, max(0, growthProgress + amount))
    }

    /// Sterne gibt es nur, solange Labubu noch nicht ganz fröhlich ist – Dauer-Tippen lohnt sich also nicht.
    mutating func pet(at now: Date = Date()) {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping else { return }
        let wasNeeded = needs.fun < 0.95
        needs.fun += Self.petAmount
        needs.clamp()
        guard wasNeeded else { return }
        petsTowardStar += 1
        if petsTowardStar >= Self.petsPerStar {
            petsTowardStar = 0
            stars += 1
        }
    }

    /// Eine kurze aktive Spielrunde macht fröhlich, hungriger und spürbar müde.
    @discardableResult
    mutating func play(at now: Date = Date()) -> Bool {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping, needs.energy >= 0.2 else { return false }
        needs.fun += 0.22
        needs.energy -= 0.18
        needs.hunger -= 0.06
        needs.clamp()
        return true
    }

    mutating func sleep(at now: Date = Date()) {
        advanceNeeds(to: now)
        guard stage == .hatched, !isSleeping else { return }
        sleepingSince = now
        sleepRewardPending = needs.energy < 0.6
    }

    mutating func wakeUp(at now: Date = Date()) {
        advanceNeeds(to: now)
        guard isSleeping else { return }
        if sleepRewardPending && needs.energy >= 0.95 {
            stars += Self.starsPerGoodSleep
        }
        sleepRewardPending = false
        sleepingSince = nil
    }

    // MARK: - Kleiderschrank

    func owns(_ item: OutfitItem) -> Bool { ownedItems.contains(item.id) }

    func isWearing(_ item: OutfitItem) -> Bool { worn[item.slot.rawValue] == item.id }

    func wornItem(in slot: OutfitSlot) -> OutfitItem? {
        worn[slot.rawValue].flatMap(OutfitItem.find)
    }

    /// Kauft ein Teil mit Sternen. `false`, wenn nicht genug Sterne da sind.
    @discardableResult
    mutating func buy(_ item: OutfitItem) -> Bool {
        guard stage == .hatched else { return false }
        if owns(item) { return true }
        guard stars >= item.price else { return false }
        stars -= item.price
        ownedItems.insert(item.id)
        return true
    }

    /// Zieht ein eigenes Teil an (ersetzt, was am selben Platz war).
    mutating func wear(_ item: OutfitItem) {
        guard owns(item) else { return }
        worn[item.slot.rawValue] = item.id
    }

    mutating func takeOff(_ slot: OutfitSlot) {
        worn[slot.rawValue] = nil
    }

    /// Nur für den Eltern-Bereich: alle Bedürfnisse fast leer, um die Pflege auszuprobieren.
    mutating func drainNeedsForTesting(at now: Date = Date()) {
        guard stage == .hatched else { return }
        needs = Needs(hunger: 0.1, fun: 0.2, energy: 0.15)
        needsUpdatedAt = now
        sleepingSince = nil
        sleepRewardPending = false
    }

    /// Nur für den Eltern-Bereich.
    mutating func addStarsForTesting(_ amount: Int) {
        guard stage == .hatched else { return }
        stars += amount
    }
}

// Ältere Spielstände kennen neuere Felder noch nicht – dann gelten die Standardwerte.
extension LabubuState {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        eggTaps = try c.decode(Int.self, forKey: .eggTaps)
        hatchedAt = try c.decodeIfPresent(Date.self, forKey: .hatchedAt)
        // Neue Auswahlen speichern nil ausdrücklich als null; alte Spielstände hatten kein Feld.
        chosenEgg = c.contains(.chosenEgg) ? try c.decodeIfPresent(EggVariant.self, forKey: .chosenEgg) : .classic
        growthProgress = min(1, max(0, try c.decodeIfPresent(Double.self, forKey: .growthProgress) ?? 0))
        needs = try c.decodeIfPresent(Needs.self, forKey: .needs) ?? .newborn
        needsUpdatedAt = try c.decodeIfPresent(Date.self, forKey: .needsUpdatedAt) ?? hatchedAt
        sleepingSince = try c.decodeIfPresent(Date.self, forKey: .sleepingSince)
        stars = try c.decodeIfPresent(Int.self, forKey: .stars) ?? 0
        ownedItems = (try c.decodeIfPresent(Set<String>.self, forKey: .ownedItems) ?? []).union(OutfitItem.freeItemIDs)
        worn = try c.decodeIfPresent([String: String].self, forKey: .worn) ?? [:]
        petsTowardStar = try c.decodeIfPresent(Int.self, forKey: .petsTowardStar) ?? 0
        sleepRewardPending = try c.decodeIfPresent(Bool.self, forKey: .sleepRewardPending) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(eggTaps, forKey: .eggTaps)
        try c.encodeIfPresent(hatchedAt, forKey: .hatchedAt)
        try c.encode(chosenEgg, forKey: .chosenEgg)
        try c.encode(growthProgress, forKey: .growthProgress)
        try c.encode(needs, forKey: .needs)
        try c.encodeIfPresent(needsUpdatedAt, forKey: .needsUpdatedAt)
        try c.encodeIfPresent(sleepingSince, forKey: .sleepingSince)
        try c.encode(stars, forKey: .stars)
        try c.encode(ownedItems, forKey: .ownedItems)
        try c.encode(worn, forKey: .worn)
        try c.encode(petsTowardStar, forKey: .petsTowardStar)
        try c.encode(sleepRewardPending, forKey: .sleepRewardPending)
    }
}
