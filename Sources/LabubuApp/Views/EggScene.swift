import SwiftUI

/// Ei-Phase: Kind tippt, Ei wackelt, Herzen füllen sich, Risse entstehen – bis Labubu schlüpft.
struct EggScene: View {
    @ObservedObject var viewModel: LabubuViewModel
    @StateObject private var motion = EggMotion()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var wobble: Double = 0
    @State private var squash: CGFloat = 1
    @State private var bursts: [UUID] = []
    @State private var showHint = true
    @State private var hintTask: Task<Void, Never>?
    @State private var strokeStartedInNest: Bool?
    @GestureState private var draggingEgg = false

    // Schlüpf-Ablauf
    @State private var hatchStarted = false
    @State private var shellOpen = false
    @State private var shellGone = false
    @State private var flash: Double = 0
    @State private var confetti = false
    @State private var labubuVisible = false

    private let sound = SoundPlayer.shared

    var body: some View {
        Group {
            if viewModel.state.chosenEgg == nil && viewModel.state.stage == .egg {
                EggSelectionView { variant in
                    viewModel.selectEgg(variant)
                    sound.play(.tap, pitchVariation: 0.1)
                }
            } else {
                incubationScene
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.state.chosenEgg)
    }

    private var incubationScene: some View {
        GeometryReader { geo in
            let height = min(geo.size.height * 0.43, geo.size.width * 0.50, 430)
            let size = CGSize(width: height * 0.8, height: height)
            let diagonal = hypot(size.width, size.height)
            let limits = CGSize(width: max(0, (geo.size.width - diagonal) / 2 - 24),
                                height: max(0, (geo.size.height - diagonal) / 2 - 135))
            ZStack {
                Ellipse()
                    .fill(.white.opacity(0.25))
                    .overlay(Ellipse().stroke(.white.opacity(0.5), lineWidth: 4))
                    .frame(width: geo.size.width - 32, height: max(height, geo.size.height - 230))
                nest(size: size)
                if labubuVisible {
                    ZStack {
                        LabubuArt()
                        BabyDiaper(growthProgress: viewModel.state.growthProgress)
                    }
                    .frame(width: size.width, height: size.height)
                    .scaleEffect(viewModel.state.growthScale, anchor: .bottom)
                    .transition(.scale(scale: 0.1, anchor: .bottom).combined(with: .opacity))
                }
                rollingEgg(size: size, tableSize: geo.size)
                ForEach(bursts, id: \.self) { _ in SparkleBurst() }
                if showHint && viewModel.state.stage == .egg {
                    HintHand().offset(x: motion.physics.position.x + size.width * 0.45,
                                      y: motion.physics.position.y + size.height * 0.3)
                        .transition(.opacity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .coordinateSpace(name: "eggTable")
            .overlay(alignment: .bottom) {
                VStack(spacing: 10) {
                    if !motion.physics.isDocked {
                        HStack { Text("👆"); Image(systemName: "arrow.down.to.line"); Text("🪺") }
                            .font(.system(size: 36))
                            .accessibilityLabel("Ziehe das Ei zurück ins Nest")
                    }
                    HeartsProgress(filled: viewModel.state.filledHearts, total: LabubuState.progressHearts)
                }
                .padding(.bottom, 30)
                .opacity(shellOpen ? 0 : 1)
            }
            .onAppear { motion.setLimits(limits) }
            .onChange(of: geo.size) { _, _ in motion.setLimits(limits) }
            .onChange(of: draggingEgg) { _, active in
                if !active && strokeStartedInNest != nil {
                    _ = motion.release(nestRadius: size.width * 0.32, nestDepth: size.height * 0.43)
                    strokeStartedInNest = nil
                }
            }
        }
        .overlay {
            Color.white.opacity(flash).ignoresSafeArea().allowsHitTesting(false)
        }
        .overlay {
            if confetti { ConfettiView().ignoresSafeArea() }
        }
        .task(id: viewModel.state.stage) {
            if viewModel.state.stage == .hatching {
                motion.stop()
                motion.dock()
                try? await runHatchSequence()
            }
        }
        .onAppear { scheduleHint(); updateMotion() }
        .onChange(of: scenePhase) { _, _ in updateMotion() }
        .onDisappear { hintTask?.cancel(); motion.stop() }
    }

    private func rollingEgg(size: CGSize, tableSize: CGSize) -> some View {
        egg(size: size)
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(reduceMotion ? 0 : max(-55, min(55, motion.physics.position.x * 0.22))))
            .contentShape(Rectangle())
            .onTapGesture(perform: tapEgg)
            .gesture(eggDrag(size: size))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Labubu-Ei")
            .accessibilityIdentifier("egg")
            .accessibilityValue(motion.physics.isDocked ? "Im Nest" : "Außerhalb des Nests")
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(motion.physics.isDocked ? "Antippen zum Wärmen" : "Zurück ins Nest ziehen")
            .accessibilityAction(named: "Ins Nest setzen") { motion.dock() }
            // Position ist Teil des Layouts: auch die System-Trefferfläche folgt dem Ei.
            .position(x: tableSize.width / 2 + motion.physics.position.x,
                      y: tableSize.height / 2 + motion.physics.position.y)
    }

    private func eggDrag(size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .named("eggTable"))
            .updating($draggingEgg) { _, active, _ in active = true }
            .onChanged { value in
                guard viewModel.state.stage == .egg else { return }
                if strokeStartedInNest == nil { strokeStartedInNest = motion.physics.isDocked }
                motion.drag(value.translation)
                showHint = false
            }
            .onEnded { value in
                if motion.release(nestRadius: size.width * 0.32, nestDepth: size.height * 0.43) {
                    sound.play(.tap, pitchVariation: 0.1)
                    let distance = hypot(value.translation.width, value.translation.height)
                    if strokeStartedInNest == true && distance < size.width * 0.22 { tapEgg() }
                }
                strokeStartedInNest = nil
                scheduleHint()
            }
    }

    private func updateMotion() {
        if scenePhase == .active && viewModel.state.stage == .egg && viewModel.state.chosenEgg != nil { motion.start() }
        else { motion.stop() }
    }

    private func nest(size: CGSize) -> some View {
        Group {
            if let image = UIImage(named: "Nest", in: .module, compatibleWith: nil) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    Ellipse().fill(Color.brown.opacity(0.5))
                    Ellipse().inset(by: 9).stroke(Color.orange.opacity(0.65), style: StrokeStyle(lineWidth: 13, dash: [4, 5]))
                    Ellipse().inset(by: 22).fill(Color(red: 1, green: 0.87, blue: 0.65))
                }
            }
        }
        .frame(width: size.width * 1.1, height: size.height * 0.2)
        .overlay(Ellipse().stroke(motion.physics.isDocked ? Color.mint.opacity(0.7) : Color.white.opacity(0.45), lineWidth: 3))
        .offset(y: size.height * 0.43)
        .allowsHitTesting(false)
    }

    private func egg(size: CGSize) -> some View {
        let crack = viewModel.state.crackLevel
        return ZStack {
            // Ganzes Ei unter den Hälften, damit an der Naht keine Haarlinie durchscheint.
            VariantEggArt(variant: viewModel.state.chosenEgg ?? .classic, crackLevel: crack)
                .opacity(shellOpen ? 0 : 1)
                .animation(nil, value: shellOpen)
            VariantEggArt(variant: viewModel.state.chosenEgg ?? .classic, crackLevel: crack)
                .clipShape(EggHalf(top: false))
                .offset(y: shellOpen ? size.height * 0.35 : 0)
                .rotationEffect(.degrees(shellOpen ? -10 : 0))
            VariantEggArt(variant: viewModel.state.chosenEgg ?? .classic, crackLevel: crack)
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
        guard viewModel.state.stage == .egg, motion.physics.isDocked else { return }
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

    private func runHatchSequence() async throws {
        guard !hatchStarted, !Task.isCancelled else { return }
        hatchStarted = true
        hintTask?.cancel()
        showHint = false
        try await Task.sleep(for: .milliseconds(300))

        // Ei zittert dreimal immer stärker.
        for strength in [10.0, 15.0, 20.0] {
            sound.play(.crack, pitchVariation: 0.1)
            withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.2)) { wobble = strength }
            try await Task.sleep(for: .milliseconds(160))
            withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.2)) { wobble = -strength }
            try await Task.sleep(for: .milliseconds(160))
            withAnimation(.easeOut(duration: 0.15)) { wobble = 0 }
            try await Task.sleep(for: .milliseconds(350))
        }

        // Aufbrechen!
        sound.play(.hatch)
        withAnimation(.easeOut(duration: 0.12)) { flash = 0.9 }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { shellOpen = true }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(0.15)) { labubuVisible = true }
        confetti = true
        try await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeIn(duration: 0.5)) { flash = 0 }
        withAnimation(.easeIn(duration: 0.6).delay(0.4)) { shellGone = true }

        try await Task.sleep(for: .seconds(3))
        viewModel.finishHatching()
    }
}
