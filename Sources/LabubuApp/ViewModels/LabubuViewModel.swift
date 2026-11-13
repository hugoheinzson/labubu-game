import Foundation
import Combine

@MainActor
final class LabubuViewModel: ObservableObject {
    @Published private(set) var state: LabubuState {
        didSet { store.save(state) }
    }

    private let store: GameStore

    init(store: GameStore = .standard) {
        self.store = store
        self.state = store.load() ?? LabubuState()
    }

    func tapEgg() {
        state.tapEgg()
    }

    func finishHatching() {
        state.finishHatching()
    }

    /// Nur über den versteckten Eltern-Bereich erreichbar.
    func resetGame() {
        state = LabubuState()
    }
}
