import SwiftUI

/// Labubus Zimmer nach dem Schlüpfen: Pflegen durch Füttern, Streicheln/Kitzeln und Schlafenlegen,
/// Sterne verdienen und im Kleiderschrank Sachen freischalten und anziehen.
struct RoomScene: View {
    @ObservedObject var viewModel: LabubuViewModel

    @State private var stageFrame: CGRect = .zero
    @State private var jump: CGFloat = 0
    @State private var shake: Double = 0
    @State private var chewing = false
    @State private var biteOpen = false
    @State private var playing = false
    @State private var targetingFood = false
    @State private var activityTask: Task<Void, Never>?
    @Environment(\.scenePhase) private var scenePhase
    @State private var bursts: [Burst] = []
    @State private var strokeDistance: CGFloat = 0
    @State private var showWardrobe = false
    @State private var counterFrame: CGRect = .zero
    @State private var counterPop = false
    @State private var flyingStars: [Flight] = []

    private struct Burst: Identifiable {
        let id = UUID()
        let symbols: [String]
    }

    private struct Flight: Identifiable {
        let id = UUID()
        let from: CGPoint
        let to: CGPoint
    }

    private var wornItems: [OutfitItem] {
        OutfitSlot.allCases.compactMap { state.wornItem(in: $0) }
    }

    private let sound = SoundPlayer.shared

    private var state: LabubuState { viewModel.state }

    /// Das Baby bekommt ein wirklich kleineres Layout, damit auch Ziehen und VoiceOver passen.
    /// Die Füße bleiben während des Wachstums an derselben Stelle auf dem Teppich.
    private var labubuFrame: CGRect {
        let size = CGSize(width: stageFrame.width * state.growthScale,
                          height: stageFrame.height * state.growthScale)
        return CGRect(x: stageFrame.midX - size.width / 2,
                      y: stageFrame.maxY - size.height,
                      width: size.width, height: size.height)
    }

    private func characterRect(in stageSize: CGSize) -> CGRect {
        let size = CGSize(width: stageSize.width * state.growthScale,
                          height: stageSize.height * state.growthScale)
        return CGRect(x: (stageSize.width - size.width) / 2,
                      y: stageSize.height - size.height,
                      width: size.width, height: size.height)
    }

    /// Mund-Position im Raum – Ziel für das Essen.
    private var mouthPoint: CGPoint {
        CGPoint(x: labubuFrame.midX, y: labubuFrame.minY + labubuFrame.height * 0.56)
    }

    var body: some View {
        ZStack {
            RoomBackground(night: state.isSleeping, floorY: labubuFrame == .zero ? nil : labubuFrame.maxY)

            StageLayout { size in
                let character = characterRect(in: size)
                ZStack {
                    ZStack {
                        LabubuArt(mood: chewing || playing ? .happy : state.mood, chewing: chewing && biteOpen)
                        OutfitLayer(items: wornItems)
                        BabyDiaper(growthProgress: state.growthProgress)
                    }
                        .frame(width: character.width, height: character.height)
                        .scaleEffect(x: biteOpen ? 1.018 : 1, y: biteOpen ? 0.985 : 1, anchor: .bottom)
                        .modifier(BreathingMotion(sleeping: state.isSleeping))
                        .rotationEffect(.degrees(shake), anchor: .bottom)
                        .offset(y: jump)
                        .brightness(state.isSleeping ? -0.2 : 0)
                        .shadow(color: .black.opacity(0.15), radius: 20, y: 16)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: tickle)
                        .gesture(strokeGesture)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Labubu")
                        .accessibilityIdentifier("labubu")
                        .accessibilityValue(chewing ? "Isst" : (playing ? "Spielt" : state.mood.rawValue))
                        .accessibilityHint(state.isBaby ? "Baby-Labubu wächst beim Füttern und Schlafen" : "Labubu")
                        .position(x: character.midX, y: character.midY)
                        .animation(.easeInOut(duration: 0.8), value: state.growthScale)

                    if targetingFood {
                        Ellipse()
                            .stroke(.white, style: StrokeStyle(lineWidth: 5, dash: [7, 5]))
                            .background(Ellipse().fill(.pink.opacity(0.25)))
                            .frame(width: max(80, character.width * 0.36), height: max(64, character.height * 0.18))
                            .position(x: character.midX, y: character.minY + character.height * 0.56)
                            .allowsHitTesting(false)
                    }

                    if state.isSleeping {
                        SleepZs().position(x: character.maxX - character.width * 0.08,
                                           y: character.minY + character.height * 0.2)
                    } else if let wish = state.wish, !chewing {
                        ThoughtBubble(emoji: emoji(for: wish))
                            .position(x: character.maxX + character.width * 0.1,
                                      y: character.minY + character.height * 0.35)
                            .transition(.scale.combined(with: .opacity))
                    }
                    ForEach(bursts) { burst in
                        SparkleBurst(symbols: burst.symbols).position(x: character.midX, y: character.midY)
                    }
                }
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .named("room")) } action: { stageFrame = $0 }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: state.wish)
            } bar: {
                HStack(alignment: .center, spacing: 10) {
                    FoodPlate(target: mouthPoint,
                              hitRadius: CGSize(width: max(40, labubuFrame.width * 0.18), height: max(32, labubuFrame.height * 0.09)),
                              enabled: labubuFrame != .zero && !state.isSleeping && !chewing && !playing,
                              onTargetingChanged: { targetingFood = $0 }, onArrive: feed)
                    Spacer()
                    RoundButton(emoji: "🏀", dimmed: state.isSleeping || playing || chewing, action: playTogether)
                        .disabled(state.isSleeping || playing || chewing)
                        .accessibilityLabel("Mit Labubu hüpfen und tanzen")
                        .accessibilityIdentifier("playButton")
                    RoundButton(emoji: "👗", dimmed: state.isSleeping) {
                        sound.play(.swish)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { showWardrobe = true }
                    }
                    .disabled(state.isSleeping || playing || chewing)
                    LampButton(lightOn: !state.isSleeping, action: toggleLight)
                        .accessibilityLabel(state.isSleeping ? "Labubu aufwecken" : "Labubu schlafen legen")
                        .accessibilityIdentifier("sleepButton")
                }
                .padding(.horizontal, 20)
                .opacity(showWardrobe ? 0 : 1)
            }

            VStack {
                ZStack(alignment: .leading) {
                    NeedsBar(needs: state.needs).frame(maxWidth: .infinity)
                    StarCounter(stars: state.stars, pop: counterPop)
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .named("room")) } action: { counterFrame = $0 }
                        .padding(.leading, 28)
                }
                .padding(.top, 28)
                Spacer()
            }

            if showWardrobe {
                VStack {
                    Spacer()
                    WardrobePanel(state: state, labubuFrame: labubuFrame, onUse: useWardrobe) {
                        sound.play(.swish, pitchVariation: 0.1)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { showWardrobe = false }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            ForEach(flyingStars) { flight in
                FlyingStar(from: flight.from, to: flight.to)
            }
        }
        .coordinateSpace(name: "room")
        .onChange(of: state.stars) { old, new in
            if new > old { celebrateStars(new - old) }
        }
        .onChange(of: state.isSleeping) { _, sleeping in
            if sleeping {
                stopActivity()
                withAnimation { showWardrobe = false }
            }
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { stopActivity() } }
        .onDisappear(perform: stopActivity)
        .task(id: state.isSleeping && scenePhase == .active) {
            // Leises Schnarchen, solange Labubu schläft.
            while state.isSleeping && scenePhase == .active && !Task.isCancelled {
                sound.play(.snore, pitchVariation: 0.05)
                try? await Task.sleep(for: .seconds(3.5))
            }
        }
    }

    private func emoji(for need: LabubuState.Need) -> String {
        switch need {
        case .hunger: return "🍓"
        case .energy: return "🛏️"
        case .fun: return "🤗"
        }
    }

    // MARK: Aktionen

    private func feed() -> Bool {
        guard !chewing, !playing else { return false }
        guard viewModel.feed() else {
            sound.play(.nope)
            shakeHead()
            return false
        }
        chewing = true
        sound.play(.hap)
        activityTask = Task { @MainActor in
            defer { biteOpen = false; chewing = false; jump = 0 }
            do {
                for _ in 0..<5 {
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.08)) { biteOpen = true; jump = -8 }
                    try await Task.sleep(for: .milliseconds(120))
                    withAnimation(.easeInOut(duration: 0.08)) { biteOpen = false; jump = 0 }
                    try await Task.sleep(for: .milliseconds(120))
                }
                addBurst(["😋", "💖"])
            } catch { }
        }
        return true
    }

    private func playTogether() {
        guard !playing, !chewing else { return }
        guard viewModel.play() else {
            addBurst(["🌙", "💤"])
            sound.play(.nope)
            return
        }
        playing = true
        activityTask = Task { @MainActor in
            defer { playing = false; jump = 0; shake = 0 }
            do {
                for turn in 0..<4 {
                    guard !Task.isCancelled else { return }
                    sound.play(.giggle, pitchVariation: 0.12)
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                        jump = -55
                        shake = turn.isMultiple(of: 2) ? -9 : 9
                    }
                    try await Task.sleep(for: .milliseconds(250))
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { jump = 0; shake = 0 }
                    try await Task.sleep(for: .milliseconds(300))
                }
                addBurst(["🎵", "💕", "✨"])
            } catch { }
        }
    }

    private func stopActivity() {
        activityTask?.cancel()
        activityTask = nil
        chewing = false
        playing = false
        biteOpen = false
        targetingFood = false
        jump = 0
        shake = 0
        sound.stopEffects()
    }

    private func tickle() {
        guard !playing, !chewing else { return }
        guard !state.isSleeping else {
            // Schläft – nur ein kleines Wackeln, kein Aufwachen.
            shakeHead(small: true)
            return
        }
        viewModel.pet()
        sound.play(.giggle, pitchVariation: 0.1)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { jump = -60 }
        Task {
            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) { jump = 0 }
        }
        addBurst(["💖", "💕", "✨"])
    }

    /// Streicheln: über Labubu wischen. Alle ~150 Punkte Wischweg zählen als einmal Streicheln.
    private var strokeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard !state.isSleeping, !playing, !chewing else { return }
                let distance = hypot(value.translation.width, value.translation.height)
                if distance - strokeDistance > 150 {
                    strokeDistance = distance
                    viewModel.pet()
                    sound.play(.giggle, pitchVariation: 0.2)
                    hop()
                    addBurst(["💕"])
                }
            }
            .onEnded { _ in strokeDistance = 0 }
    }

    private func toggleLight() {
        sound.play(.click)
        withAnimation(.easeInOut(duration: 0.6)) { viewModel.toggleSleep() }
        if !state.isSleeping {
            addBurst(["☀️", "✨"])
        }
    }

    private func useWardrobe(_ item: OutfitItem) -> LabubuViewModel.WardrobeResult {
        let result = withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            viewModel.useWardrobeItem(item)
        }
        switch result {
        case .putOn:
            sound.play(.swish)
            hop()
            addBurst(["✨", "💖"])
        case .bought:
            sound.play(.unlock)
            hop()
            addBurst(["🎉", "⭐️", "✨"])
        case .tookOff:
            sound.play(.swish, pitchVariation: 0.2)
        case .tooExpensive:
            sound.play(.nope)
        }
        return result
    }

    /// Für jeden neuen Stern fliegt ein Stern von Labubu zum Konto.
    private func celebrateStars(_ count: Int) {
        let from = CGPoint(x: labubuFrame.midX, y: labubuFrame.minY + labubuFrame.height * 0.3)
        let to = CGPoint(x: counterFrame.minX + 40, y: counterFrame.midY)
        for i in 0..<min(count, 5) {
            Task {
                try? await Task.sleep(for: .milliseconds(150 * i + 250))
                let flight = Flight(from: from, to: to)
                flyingStars.append(flight)
                try? await Task.sleep(for: .milliseconds(750))
                flyingStars.removeAll { $0.id == flight.id }
                sound.play(.star, pitchVariation: 0.05)
                counterPop = true
                try? await Task.sleep(for: .milliseconds(150))
                counterPop = false
            }
        }
    }

    private func hop() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { jump = -40 }
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) { jump = 0 }
        }
    }

    private func shakeHead(small: Bool = false) {
        let angle = small ? 3.0 : 9.0
        Task {
            for direction in [1.0, -1.0, 1.0, -1.0] {
                withAnimation(.easeInOut(duration: 0.08)) { shake = angle * direction }
                try? await Task.sleep(for: .milliseconds(90))
            }
            withAnimation(.spring) { shake = 0 }
        }
    }

    private func addBurst(_ symbols: [String]) {
        let burst = Burst(symbols: symbols)
        bursts.append(burst)
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            bursts.removeAll { $0.id == burst.id }
        }
    }
}
