import SwiftUI

/// Ei-Phase: Kind tippt, Ei wackelt, Herzen füllen sich, Risse entstehen – bis Labubu schlüpft.
struct EggScene: View {
    @ObservedObject var viewModel: LabubuViewModel

    @State private var wobble: Double = 0
    @State private var squash: CGFloat = 1
    @State private var bursts: [UUID] = []
    @State private var showHint = true
    @State private var hintTask: Task<Void, Never>?

    // Schlüpf-Ablauf
    @State private var hatchStarted = false
    @State private var shellOpen = false
    @State private var shellGone = false
    @State private var flash: Double = 0
    @State private var confetti = false
    @State private var labubuVisible = false

    private let sound = SoundPlayer.shared

    var body: some View {
        StageLayout { size in
            ZStack {
                if labubuVisible {
                    LabubuArt()
                        .transition(.scale(scale: 0.1, anchor: .bottom).combined(with: .opacity))
                }
                egg(size: size)
                ForEach(bursts, id: \.self) { _ in SparkleBurst() }
                if showHint && viewModel.state.stage == .egg {
                    HintHand().offset(x: size.width * 0.45, y: size.height * 0.3)
                        .transition(.opacity)
                }
            }
        } bar: {
            HeartsProgress(filled: viewModel.state.filledHearts, total: LabubuState.progressHearts)
                .opacity(shellOpen ? 0 : 1)
                .animation(.easeOut, value: shellOpen)
        }
        // Ganzer Bildschirm ist Tipp-Fläche – kleine Finger treffen nicht immer genau.
        .contentShape(Rectangle())
        .onTapGesture(perform: tapEgg)
        .overlay {
            Color.white.opacity(flash).ignoresSafeArea().allowsHitTesting(false)
        }
        .overlay {
            if confetti { ConfettiView().ignoresSafeArea() }
        }
        .task(id: viewModel.state.stage) {
            if viewModel.state.stage == .hatching { await runHatchSequence() }
        }
        .onAppear(perform: scheduleHint)
        .onDisappear { hintTask?.cancel() }
    }

    private func egg(size: CGSize) -> some View {
        let crack = viewModel.state.crackLevel
        return ZStack {
            // Ganzes Ei unter den Hälften, damit an der Naht keine Haarlinie durchscheint.
            EggArt(crackLevel: crack)
                .opacity(shellOpen ? 0 : 1)
                .animation(nil, value: shellOpen)
            EggArt(crackLevel: crack)
                .clipShape(EggHalf(top: false))
                .offset(y: shellOpen ? size.height * 0.35 : 0)
                .rotationEffect(.degrees(shellOpen ? -10 : 0))
            EggArt(crackLevel: crack)
                .clipShape(EggHalf(top: true))
                .rotationEffect(.degrees(shellOpen ? 40 : 0), anchor: .bottomTrailing)
                .offset(x: shellOpen ? size.width * 0.5 : 0, y: shellOpen ? -size.height * 0.7 : 0)
        }
        .opacity(shellGone ? 0 : 1)
        .rotationEffect(.degrees(wobble), anchor: .bottom)
        .scaleEffect(x: 2 - squash, y: squash, anchor: .bottom)
        // Erst zu einem Bild zusammensetzen, dann Schatten: Sonst wirft die obere Hälfte einen
        // Schatten auf die untere, und das Ei sieht schon vor dem ersten Tipp gebrochen aus.
        .compositingGroup()
        .shadow(color: .black.opacity(0.18), radius: 24, y: 18)
    }

    private func tapEgg() {
        guard viewModel.state.stage == .egg else { return }
        let cracksBefore = viewModel.state.crackLevel
        viewModel.tapEgg()
        sound.play(viewModel.state.crackLevel > cracksBefore ? .crack : .tap, pitchVariation: 0.15)

        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.3)) {
            wobble = .random(in: 8...14) * (Bool.random() ? 1 : -1)
            squash = 0.92
        }
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.35, dampingFraction: 0.4)) {
                wobble = 0
                squash = 1
            }
        }

        let id = UUID()
        bursts.append(id)
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            bursts.removeAll { $0 == id }
        }

        withAnimation { showHint = false }
        scheduleHint()
    }

    /// Hand erscheint wieder, wenn eine Weile nicht getippt wurde.
    private func scheduleHint() {
        hintTask?.cancel()
        hintTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation { showHint = true }
        }
    }

    private func runHatchSequence() async {
        guard !hatchStarted else { return }
        hatchStarted = true
        hintTask?.cancel()
        showHint = false
        try? await Task.sleep(for: .milliseconds(300))

        // Ei zittert dreimal immer stärker.
        for strength in [10.0, 15.0, 20.0] {
            sound.play(.crack, pitchVariation: 0.1)
            withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.2)) { wobble = strength }
            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.2)) { wobble = -strength }
            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.easeOut(duration: 0.15)) { wobble = 0 }
            try? await Task.sleep(for: .milliseconds(350))
        }

        // Aufbrechen!
        sound.play(.hatch)
        withAnimation(.easeOut(duration: 0.12)) { flash = 0.9 }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { shellOpen = true }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(0.15)) { labubuVisible = true }
        confetti = true
        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeIn(duration: 0.5)) { flash = 0 }
        withAnimation(.easeIn(duration: 0.6).delay(0.4)) { shellGone = true }

        try? await Task.sleep(for: .seconds(3))
        viewModel.finishHatching()
    }
}
