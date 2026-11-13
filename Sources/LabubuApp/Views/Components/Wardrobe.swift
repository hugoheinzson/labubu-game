import SwiftUI

/// Sterne-Konto oben links. Zahl plus Stern – kleine Zahlen kennen Kinder mit 5–6 meist schon.
struct StarCounter: View {
    let stars: Int
    let pop: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text("⭐️").font(.system(size: 44))
            Text("\(stars)")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.55, green: 0.35, blue: 0.1))
                .contentTransition(.numericText(value: Double(stars)))
                .monospacedDigit()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.yellow.opacity(0.8), lineWidth: 4))
        .scaleEffect(pop ? 1.25 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: pop)
        .animation(.default, value: stars)
    }
}

/// Stern, der von Labubu zum Sterne-Konto fliegt.
struct FlyingStar: View {
    let from: CGPoint
    let to: CGPoint
    @State private var arrived = false

    var body: some View {
        Text("⭐️")
            .font(.system(size: arrived ? 40 : 70))
            .position(arrived ? to : from)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.75)) { arrived = true }
            }
    }
}

/// Runder Knopf in der unteren Leiste (Kleiderschrank, Licht).
struct RoundButton: View {
    let emoji: String
    var glowing = false
    var dimmed = false
    var background: Color = .white.opacity(0.6)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(background)
                    .overlay(Circle().stroke(.white, lineWidth: 5))
                    .shadow(color: glowing ? .yellow.opacity(0.8) : .black.opacity(0.1), radius: glowing ? 24 : 6)
                Text(emoji)
                    .font(.system(size: 54))
                    .grayscale(dimmed ? 1 : 0)
                    .opacity(dimmed ? 0.6 : 1)
            }
            .frame(width: 104, height: 104)
        }
        .buttonStyle(.plain)
    }
}

/// Kleiderschrank: alle Teile als große Kacheln. Antippen oder auf Labubu ziehen zieht an.
struct WardrobePanel: View {
    let state: LabubuState
    /// Labubus Rahmen im Raum – Ziel fürs Ziehen.
    let labubuFrame: CGRect
    let onUse: (OutfitItem) -> LabubuViewModel.WardrobeResult
    let onClose: () -> Void

    /// Zwei kompakte Reihen, damit Labubu darüber sichtbar bleibt und man sieht, was es trägt.
    private static let columns = 7

    private var rows: [[OutfitItem]] {
        stride(from: 0, to: OutfitItem.catalog.count, by: Self.columns).map {
            Array(OutfitItem.catalog[$0..<min($0 + Self.columns, OutfitItem.catalog.count)])
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Text("✖️")
                    .font(.system(size: 30))
                    .frame(width: 70, height: 2 * WardrobeCell.size + 8)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white))
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 8) {
                        ForEach(row) { item in
                            WardrobeCell(
                                item: item,
                                owned: state.owns(item),
                                worn: state.isWearing(item),
                                affordable: state.stars >= item.price,
                                labubuFrame: labubuFrame,
                                onUse: { onUse(item) }
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(.white.opacity(0.45)))
                .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(.white, lineWidth: 4))
        )
    }
}

private struct WardrobeCell: View {
    static let size: CGFloat = 88

    let item: OutfitItem
    let owned: Bool
    let worn: Bool
    let affordable: Bool
    let labubuFrame: CGRect
    let onUse: () -> LabubuViewModel.WardrobeResult

    /// Setzt sich von selbst zurück (mit Feder), auch wenn das System die Geste abbricht.
    @GestureState(resetTransaction: Transaction(animation: .spring(response: 0.4, dampingFraction: 0.6)))
    private var drag: CGSize = .zero
    @State private var shake: CGFloat = 0

    private var dragging: Bool { drag != .zero }

    private var canBuy: Bool { !owned && affordable }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !canBuy)) { context in
            let pulse = canBuy ? 1 + 0.05 * sin(context.date.timeIntervalSinceReferenceDate * 5) : 1
            tile.scaleEffect(pulse)
        }
        .offset(x: drag.width + shake, y: drag.height)
        .zIndex(dragging ? 10 : 0)
        .onTapGesture { use() }
        .gesture(
            DragGesture(minimumDistance: 8, coordinateSpace: .named("room"))
                .updating($drag) { value, state, _ in state = value.translation }
                .onEnded { value in
                    if labubuFrame.insetBy(dx: -40, dy: -40).contains(value.location) && !worn {
                        use()
                    }
                }
        )
    }

    private var tile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(owned ? 0.95 : 0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(worn ? Color.pink : (canBuy ? Color.yellow : .clear), lineWidth: 5)
                )
            VStack(spacing: 2) {
                Text(item.emoji)
                    .font(.system(size: owned ? 50 : 40))
                    .opacity(owned ? 1 : 0.45)
                if !owned {
                    // Preis als Sterne zum Zählen statt als Zahl.
                    HStack(spacing: 0) {
                        ForEach(0..<item.price, id: \.self) { _ in
                            Text("⭐️").font(.system(size: 13))
                        }
                    }
                }
            }
            if !owned {
                Text("🔒").font(.system(size: 20)).position(x: 15, y: 15)
            }
            if worn {
                Text("✅").font(.system(size: 22)).position(x: Self.size - 14, y: 14)
            }
        }
        .frame(width: Self.size, height: Self.size)
        .scaleEffect(dragging ? 1.15 : 1)
    }

    private func use() {
        if onUse() == .tooExpensive {
            Task {
                for direction in [1.0, -1.0, 1.0, -1.0] {
                    withAnimation(.easeInOut(duration: 0.07)) { shake = 10 * direction }
                    try? await Task.sleep(for: .milliseconds(75))
                }
                withAnimation(.spring) { shake = 0 }
            }
        }
    }
}
