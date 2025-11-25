import Foundation
import Combine

@MainActor
final class LabubuViewModel: ObservableObject {
    @Published private(set) var state = LabubuState()

    private var lastCareDate: Date?

    func careForEgg() {
        let now = Date()
        let delta = min(now.timeIntervalSince(lastCareDate ?? now), 5)
        lastCareDate = now
        state.applyCare(amount: delta / 5)
    }

    func warmthLabel() -> String {
        "Wärme: \(Int(state.warmth * 100))%"
    }

    func progressLabel() -> String {
        "Pflege: \(Int(state.careProgress * 100))%"
    }

    func stageDescription() -> String {
        switch state.stage {
        case .egg:
            return "Ei"
        case .incubating:
            return "Am Wärmen"
        case .hatched:
            return "Labubu ist da!"
        }
    }
}
