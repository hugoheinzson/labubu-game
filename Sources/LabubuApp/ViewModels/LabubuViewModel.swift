import Foundation
import Combine

@MainActor
final class LabubuViewModel: ObservableObject {
    @Published private(set) var state: LabubuState {
        didSet { store.save(state) }
    }

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

    func toggleSleep() {
        if state.isSleeping {
            state.wakeUp()
        } else {
            state.sleep()
        }
    }

    // MARK: Eltern-Bereich

    func resetGame() {
        state = LabubuState()
    }

    func drainNeedsForTesting() {
        state.drainNeedsForTesting()
    }
}
