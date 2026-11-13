import Foundation
import Combine

@MainActor
final class LabubuViewModel: ObservableObject {
    @Published private(set) var state: LabubuState {
        didSet { store.save(state) }
    }
    @Published private(set) var eggSessionID = UUID()

    private let store: GameStore
    private var ticker: AnyCancellable?

    init(store: GameStore = .standard, tickInterval: TimeInterval? = 2) {
        self.store = store
        self.state = store.load() ?? LabubuState()
        tick()
        if let tickInterval {
            ticker = Timer.publish(every: tickInterval, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] now in self?.tick(now: now) }
        }
    }

    /// Schreibt die Bedürfnisse auf die aktuelle Uhrzeit fort. Läuft regelmäßig und beim Zurückkehren in die App.
    func tick(now: Date = Date()) {
        guard state.stage == .hatched else { return }
        state.advanceNeeds(to: now)
    }

    func tapEgg() {
        state.tapEgg()
    }

    func selectEgg(_ variant: EggVariant) {
        state.selectEgg(variant)
    }

    func finishHatching() {
        state.finishHatching()
    }

    @discardableResult
    func feed() -> Bool {
        state.feed()
    }

    func pet() {
        state.pet()
    }

    @discardableResult
    func play() -> Bool { state.play() }

    func toggleSleep() {
        if state.isSleeping {
            state.wakeUp()
        } else {
            state.sleep()
        }
    }

    // MARK: Kleiderschrank

    /// Antippen im Kleiderschrank: kaufen (falls nötig), dann an- bzw. ausziehen.
    enum WardrobeResult { case putOn, tookOff, bought, tooExpensive }

    func useWardrobeItem(_ item: OutfitItem) -> WardrobeResult {
        if state.isWearing(item) {
            state.takeOff(item.slot)
            return .tookOff
        }
        let wasOwned = state.owns(item)
        guard state.buy(item) else { return .tooExpensive }
        state.wear(item)
        return wasOwned ? .putOn : .bought
    }

    // MARK: Eltern-Bereich

    func resetGame() {
        eggSessionID = UUID()
        state = LabubuState()
    }

    func startNewEgg() {
        eggSessionID = UUID()
        state.startNewEgg()
    }

    func drainNeedsForTesting() {
        state.drainNeedsForTesting()
    }

    func addStarsForTesting() {
        state.addStarsForTesting(10)
    }
}
