import SwiftUI

/// Labubu ist geschlüpft. Antippen bringt es zum Kichern und Hüpfen.
/// Ab Woche 2 kommen hier Zimmer und Pflege-Symbole dazu.
struct HatchedScene: View {
    @State private var breathe = false
    @State private var jump: CGFloat = 0
    @State private var bursts: [UUID] = []

    private let sound = SoundPlayer.shared

    var body: some View {
        StageLayout { _ in
            ZStack {
                LabubuArt()
                    .scaleEffect(x: breathe ? 1.02 : 0.99, y: breathe ? 0.98 : 1.02, anchor: .bottom)
                    .offset(y: jump)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 16)
                ForEach(bursts, id: \.self) { _ in SparkleBurst(symbols: ["💖", "💕", "✨"]) }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: giggle)
        } bar: {
            Color.clear
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { breathe = true }
        }
    }

    private func giggle() {
        sound.play(.giggle, pitchVariation: 0.1)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { jump = -60 }
        Task {
            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) { jump = 0 }
        }
        let id = UUID()
        bursts.append(id)
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            bursts.removeAll { $0 == id }
        }
    }
}
