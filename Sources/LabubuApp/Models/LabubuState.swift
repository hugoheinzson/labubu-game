import Foundation

enum HatchStage: String, Codable, CaseIterable {
    case egg
    case incubating
    case hatched
}

struct LabubuState: Codable {
    private(set) var warmth: Double = 0
    private(set) var careProgress: Double = 0
    private(set) var stage: HatchStage = .egg

    mutating func applyCare(amount: Double) {
        let clamped = max(0, min(1, amount))
        warmth = min(1, warmth + clamped * 0.6)
        careProgress = min(1, careProgress + clamped * 0.4)
        stage = nextStage()
    }

    private func nextStage() -> HatchStage {
        if careProgress >= 1 {
            return .hatched
        }
        if warmth >= 0.5 {
            return .incubating
        }
        return .egg
    }
}
