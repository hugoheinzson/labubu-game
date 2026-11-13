import SwiftUI

/// Sanftes Atmen mit festem Standpunkt; im Schlaf langsamer als im Wachzustand.
struct BreathingMotion: ViewModifier {
    let sleeping: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion || scenePhase != .active)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let period = sleeping ? 5.5 : 3.2
            let breath = reduceMotion ? 0 : (sin(time * 2 * .pi / period) + 1) / 2
            content
                .scaleEffect(
                    x: 1 + breath * 0.006,
                    y: 1 + breath * (sleeping ? 0.018 : 0.012),
                    anchor: .bottom
                )
        }
    }
}
