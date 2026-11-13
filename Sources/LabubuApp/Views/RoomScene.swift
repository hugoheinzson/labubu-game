import SwiftUI

/// Labubus Zimmer nach dem Schlüpfen: Pflegen durch Füttern, Streicheln/Kitzeln und Schlafenlegen,
/// Sterne verdienen und im Kleiderschrank Sachen freischalten und anziehen.
struct RoomScene: View {
    @ObservedObject var viewModel: LabubuViewModel

    @State private var labubuFrame: CGRect = .zero
    @State private var breathe = false
    @State private var jump: CGFloat = 0
    @State private var shake: Double = 0
    @State private var chewing = false
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

    /// Mund-Position im Raum – Ziel für das Essen.
    private var mouthPoint: CGPoint {
        CGPoint(x: labubuFrame.midX, y: labubuFrame.minY + labubuFrame.height * 0.6)
    }

    var body: some View {
        ZStack {
            RoomBackground(night: state.isSleeping, floorY: labubuFrame == .zero ? nil : labubuFrame.maxY)

            StageLayout { size in
                ZStack {
                    ZStack {
                        LabubuArt(mood: state.mood, chewing: chewing)
                        OutfitLayer(items: wornItems)
                    }
                        .scaleEffect(x: breathe ? 1.02 : 0.99, y: breathe ? 0.98 : 1.02, anchor: .bottom)
                        .rotationEffect(.degrees(shake), anchor: .bottom)
                        .offset(y: jump)
                        .brightness(state.isSleeping ? -0.2 : 0)
                        .shadow(color: .black.opacity(0.15), radius: 20, y: 16)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: tickle)
                        .gesture(strokeGesture)

                    if state.isSleeping {
                        SleepZs().offset(x: size.width * 0.3, y: -size.height * 0.35)
                    } else if let wish = state.wish, !chewing {
                        ThoughtBubble(emoji: emoji(for: wish))
                            .offset(x: size.width * 0.62, y: -size.height * 0.42)
                            .transition(.scale.combined(with: .opacity))
                    }
                    ForEach(bursts) { burst in SparkleBurst(symbols: burst.symbols) }
                }
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .named("room")) } action: { labubuFrame = $0 }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: state.wish)
            } bar: {
                HStack(alignment: .center, spacing: 20) {
                    FoodPlate(target: mouthPoint, enabled: !state.isSleeping, onArrive: feed)
                    Spacer()
                    RoundButton(emoji: "👗", dimmed: state.isSleeping) {
                        sound.play(.swish)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { showWardrobe = true }
                    }
                    .disabled(state.isSleeping)
                    LampButton(lightOn: !state.isSleeping, action: toggleLight)
                }
                .padding(.horizontal, 40)
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
            if sleeping { withAnimation { showWardrobe = false } }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { breathe = true }
        }
        .task(id: state.isSleeping) {
            // Leises Schnarchen, solange Labubu schläft.
            while state.isSleeping && !Task.isCancelled {
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
        guard viewModel.feed() else {
            sound.play(.nope)
            shakeHead()
            return false
        }
        sound.play(.chomp, pitchVariation: 0.1)
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) { chewing = true; jump = -18 }
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { jump = 0 }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation { chewing = false }
        }
        addBurst(["😋", "✨", "💖"])
        return true
    }

    private func tickle() {
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
                guard !state.isSleeping else { return }
                let distance = hypot(value.translation.width, value.translation.height)
                if distance - strokeDistance > 150 {
                    strokeDistance = distance
                    viewModel.pet()
                    sound.play(.giggle, pitchVariation: 0.2)
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
