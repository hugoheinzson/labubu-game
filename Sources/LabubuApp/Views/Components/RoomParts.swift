import SwiftUI

/// Labubus Zimmer: Wand, Fenster, Boden, Teppich. Nachts (Licht aus) wird es dunkel und draußen leuchten Sterne.
struct RoomBackground: View {
    let night: Bool
    /// Y-Position von Labubus Füßen im Raum – dort liegen Boden und Teppich. nil = Schätzung.
    var floorY: CGFloat?

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let feet = floorY.map { $0 - geo.frame(in: .named("room")).minY } ?? h * 0.65
            ZStack {
                LinearGradient(colors: [Color(red: 1, green: 0.88, blue: 0.9), Color(red: 0.95, green: 0.85, blue: 1)],
                               startPoint: .top, endPoint: .bottom)
                let windowSize = min(w * 0.28, 260)
                window
                    .frame(width: windowSize, height: windowSize * 1.1)
                    .position(x: w * 0.2, y: max(h * 0.2, 150 + windowSize * 0.55))
                // Boden
                Rectangle()
                    .fill(LinearGradient(colors: [Color(red: 0.98, green: 0.86, blue: 0.74), Color(red: 0.93, green: 0.78, blue: 0.66)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(height: h - feet + 80)
                    .position(x: w / 2, y: (feet - 80 + h) / 2)
                // Teppich unter Labubu
                Ellipse()
                    .fill(Color(red: 0.75, green: 0.9, blue: 0.88))
                    .overlay(Ellipse().inset(by: 14).stroke(.white.opacity(0.7), style: StrokeStyle(lineWidth: 6, dash: [14, 10])))
                    .frame(width: w * 0.6, height: h * 0.1)
                    .position(x: w / 2, y: feet - 6)
                Color(red: 0.08, green: 0.06, blue: 0.25)
                    .opacity(night ? 0.55 : 0)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: night)
    }

    private var window: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(night
                      ? LinearGradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.35), Color(red: 0.25, green: 0.2, blue: 0.5)], startPoint: .top, endPoint: .bottom)
                      : LinearGradient(colors: [Color(red: 0.6, green: 0.85, blue: 1), Color(red: 0.85, green: 0.95, blue: 1)], startPoint: .top, endPoint: .bottom))
            Text(night ? "🌙" : "☀️").font(.system(size: 54)).offset(x: 30, y: -40)
            Text(night ? "⭐️" : "☁️").font(.system(size: night ? 26 : 50)).offset(x: -40, y: night ? -10 : 30)
            if night { Text("✨").font(.system(size: 22)).offset(x: 10, y: 50) }
            // Fensterkreuz
            Rectangle().fill(.white).frame(width: 10)
            Rectangle().fill(.white).frame(height: 10)
            RoundedRectangle(cornerRadius: 24).stroke(.white, lineWidth: 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

/// Ein Bedürfnis als große Blase, die sich von unten füllt. Ist sie fast leer, pulsiert sie.
struct NeedBubble: View {
    let emoji: String
    let level: Double
    let tint: Color

    private let size: CGFloat = 92
    private var isLow: Bool { level < Needs.lowThreshold }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isLow)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let pulse = isLow ? 1 + 0.08 * sin(t * 6) : 1
            ZStack(alignment: .bottom) {
                Circle().fill(.white.opacity(0.55))
                Rectangle()
                    .fill(tint.opacity(0.8))
                    .frame(height: size * level)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 5))
            .overlay(Text(emoji).font(.system(size: 46)))
            .scaleEffect(pulse)
            .animation(.easeInOut(duration: 0.6), value: level)
        }
    }
}

struct NeedsBar: View {
    let needs: Needs

    var body: some View {
        HStack(spacing: 22) {
            NeedBubble(emoji: "🍓", level: needs.hunger, tint: Color(red: 1, green: 0.45, blue: 0.5))
            NeedBubble(emoji: "💖", level: needs.fun, tint: Color(red: 1, green: 0.6, blue: 0.85))
            NeedBubble(emoji: "🌙", level: needs.energy, tint: Color(red: 0.55, green: 0.55, blue: 1))
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

/// Denkblase mit dem, was Labubu gerade möchte – verständlich ohne Lesen.
struct ThoughtBubble: View {
    let emoji: String
    @State private var bob = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Circle().fill(.white).frame(width: 18, height: 18).offset(x: -18, y: 34)
            Circle().fill(.white).frame(width: 28, height: 28).offset(x: 0, y: 10)
            ZStack {
                Ellipse().fill(.white).frame(width: 130, height: 110)
                Text(emoji).font(.system(size: 62))
            }
            .offset(x: 20, y: -30)
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .offset(y: bob ? -8 : 8)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { bob = true }
        }
    }
}

/// Aufsteigende „Z“ über dem schlafenden Labubu.
struct SleepZs: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    let phase = (t * 0.4 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
                    Text("Z")
                        .font(.system(size: 30 + phase * 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(x: phase * 60, y: -phase * 150)
                        .opacity(1 - phase)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

/// Großer Lichtschalter: Licht aus = Labubu schläft.
struct LampButton: View {
    let lightOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(lightOn ? Color.yellow.opacity(0.35) : Color(red: 0.15, green: 0.15, blue: 0.4))
                    .overlay(Circle().stroke(.white, lineWidth: 5))
                    .shadow(color: lightOn ? .yellow.opacity(0.8) : .clear, radius: 24)
                Text("💡")
                    .font(.system(size: 54))
                    .grayscale(lightOn ? 0 : 1)
                    .opacity(lightOn ? 1 : 0.6)
            }
            .frame(width: 104, height: 104)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.3), value: lightOn)
    }
}

/// Teller mit drei Essen. Antippen oder zu Labubu ziehen füttert.
struct FoodPlate: View {
    /// Mitte von Labubus Mund im Koordinatenraum „room“.
    let target: CGPoint
    let enabled: Bool
    /// Wird aufgerufen, wenn das Essen bei Labubu ankommt. `true` = gegessen, `false` = abgelehnt.
    let onArrive: () -> Bool

    private struct Slot: Identifiable {
        let id = UUID()
        let emoji: String
    }

    private static let menu = ["🍓", "🍎", "🍪", "🥕", "🍌", "🧁", "🍇", "🥞"]

    @State private var slots: [Slot] = (0..<3).map { _ in Slot(emoji: FoodPlate.menu.randomElement()!) }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(slots) { slot in
                FoodItem(emoji: slot.emoji, target: target, onArrive: onArrive) {
                    replace(slot.id)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(.white.opacity(0.85))
                .overlay(Capsule().stroke(Color(red: 1, green: 0.7, blue: 0.8), lineWidth: 6))
        )
        .opacity(enabled ? 1 : 0.4)
        .allowsHitTesting(enabled)
        .animation(.easeInOut, value: enabled)
    }

    private func replace(_ id: UUID) {
        guard let index = slots.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            slots[index] = Slot(emoji: Self.menu.randomElement()!)
        }
    }
}

private struct FoodItem: View {
    let emoji: String
    let target: CGPoint
    let onArrive: () -> Bool
    let onEaten: () -> Void

    @State private var home: CGRect = .zero
    @State private var offset: CGSize = .zero
    @State private var dragging = false
    @State private var eaten = false
    @State private var busy = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 62))
            .frame(width: 92, height: 92)
            .contentShape(Rectangle())
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .named("room")) } action: { home = $0 }
            .scaleEffect(eaten ? 0.1 : (dragging ? 1.3 : 1))
            .opacity(eaten ? 0 : 1)
            .offset(offset)
            .zIndex(dragging || busy ? 10 : 0)
            .onTapGesture { deliver() }
            .gesture(
                DragGesture(minimumDistance: 6, coordinateSpace: .named("room"))
                    .onChanged { value in
                        guard !busy else { return }
                        dragging = true
                        offset = value.translation
                    }
                    .onEnded { value in
                        dragging = false
                        let close = hypot(value.location.x - target.x, value.location.y - target.y) < 170
                        if close { deliver() } else { springHome() }
                    }
            )
            .transition(.scale.combined(with: .opacity))
    }

    private func deliver() {
        guard !busy else { return }
        busy = true
        withAnimation(.easeIn(duration: 0.3)) {
            offset = CGSize(width: target.x - home.midX, height: target.y - home.midY)
        }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            if onArrive() {
                withAnimation(.easeIn(duration: 0.25)) { eaten = true }
                try? await Task.sleep(for: .milliseconds(450))
                onEaten()
            } else {
                springHome()
            }
        }
    }

    private func springHome() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) { offset = .zero }
        busy = false
    }
}
