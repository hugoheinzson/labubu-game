import SwiftUI

/// Kleine Explosion aus Emojis, z. B. beim Antippen des Eis.
struct SparkleBurst: View {
    var symbols: [String] = ["✨", "💖", "⭐️", "🌸"]

    private struct Particle {
        let angle: Double
        let distance: CGFloat
        let symbol: String
    }

    @State private var particles: [Particle] = []
    @State private var exploded = false

    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { i in
                let p = particles[i]
                Text(p.symbol)
                    .font(.system(size: 44))
                    .scaleEffect(exploded ? 1.2 : 0.4)
                    .offset(x: exploded ? cos(p.angle) * p.distance : 0,
                            y: exploded ? sin(p.angle) * p.distance : 0)
                    .opacity(exploded ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            particles = (0..<7).map { i in
                Particle(angle: Double(i) / 7 * 2 * .pi + .random(in: -0.3...0.3),
                         distance: .random(in: 140...230),
                         symbol: symbols.randomElement() ?? "✨")
            }
            withAnimation(.easeOut(duration: 0.8)) { exploded = true }
        }
    }
}

/// Konfetti-Regen beim Schlüpfen.
struct ConfettiView: View {
    private struct Piece {
        let x: CGFloat
        let delay: Double
        let duration: Double
        let spin: Double
        let color: Color
        let size: CGSize
    }

    @State private var pieces: [Piece] = []
    @State private var falling = false

    var body: some View {
        GeometryReader { geo in
            ForEach(pieces.indices, id: \.self) { i in
                let p = pieces[i]
                RoundedRectangle(cornerRadius: 3)
                    .fill(p.color)
                    .frame(width: p.size.width, height: p.size.height)
                    .rotationEffect(.degrees(falling ? p.spin : 0))
                    .position(x: p.x * geo.size.width, y: falling ? geo.size.height + 40 : -40)
                    .animation(.easeIn(duration: p.duration).delay(p.delay), value: falling)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            let colors: [Color] = [.pink, .yellow, .mint, .purple, .orange, .cyan, .white]
            pieces = (0..<70).map { _ in
                Piece(x: .random(in: 0...1), delay: .random(in: 0...0.8), duration: .random(in: 1.8...3.2),
                      spin: .random(in: 360...1080), color: colors.randomElement()!,
                      size: CGSize(width: .random(in: 10...18), height: .random(in: 16...28)))
            }
            DispatchQueue.main.async { falling = true }
        }
    }
}

/// Wippende Hand, die zeigt: hier tippen!
struct HintHand: View {
    @State private var bob = false

    var body: some View {
        Text("👆")
            .font(.system(size: 90))
            .rotationEffect(.degrees(-20))
            .offset(y: bob ? -14 : 14)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bob = true }
            }
    }
}

/// Fortschritt als Herzen statt Prozent – verständlich ohne Lesen und Zahlen.
struct HeartsProgress: View {
    let filled: Int
    let total: Int

    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<total, id: \.self) { i in
                Image(systemName: i < filled ? "heart.fill" : "heart")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(i < filled ? Color.pink : Color.white.opacity(0.8))
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: i < filled)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .background(.ultraThinMaterial, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ei-Wärme")
        .accessibilityValue("\(filled) von \(total)")
        .accessibilityIdentifier("heartsProgress")
    }
}
