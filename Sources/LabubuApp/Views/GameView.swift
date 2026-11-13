import SwiftUI

/// Rahmen um alle Szenen: Hintergrund, Szenenwechsel und versteckter Eltern-Bereich.
struct GameView: View {
    @ObservedObject var viewModel: LabubuViewModel
    @State private var showParentMenu = false
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("audioMuted") private var audioMuted = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1, green: 0.8, blue: 0.86), Color(red: 0.86, green: 0.74, blue: 1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            switch viewModel.state.stage {
            case .egg, .hatching:
                EggScene(viewModel: viewModel)
                    .id(viewModel.eggSessionID)
                    .transition(.opacity)
            case .hatched:
                RoomScene(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: viewModel.state.stage == .hatched)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                Button {
                    SoundPlayer.shared.stopEffects()
                    viewModel.startNewEgg()
                    SoundPlayer.shared.play(.tap)
                } label: {
                    Text("🥚").font(.system(size: 48))
                        .frame(width: 96, height: 96)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 3))
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(.indigo, .white)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Neues Ei starten")
                .accessibilityHint("Sterne und Kleidung bleiben erhalten")
                .accessibilityIdentifier("newEggButton")
                Button {
                    audioMuted.toggle()
                } label: {
                    Image(systemName: audioMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(audioMuted ? Color.secondary : Color.indigo)
                        .frame(width: 96, height: 96)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 3))
                }
                .buttonStyle(.plain)
                .highPriorityGesture(LongPressGesture(minimumDuration: 3).onEnded { _ in showParentMenu = true })
                .accessibilityAction(named: "Eltern-Bereich öffnen") { showParentMenu = true }
                .accessibilityLabel(audioMuted ? "Ton einschalten" : "Ton ausschalten")
                .accessibilityValue(audioMuted ? "Stumm" : "Ton an")
            }
            .padding(24)
        }
        .confirmationDialog("Eltern-Bereich", isPresented: $showParentMenu, titleVisibility: .visible) {
            Button(musicEnabled ? "Musik ausschalten" : "Musik einschalten") { musicEnabled.toggle() }
            Button(soundEnabled ? "Geräusche ausschalten" : "Geräusche einschalten") { soundEnabled.toggle() }
            if viewModel.state.stage == .hatched {
                Button("Bedürfnisse leeren (zum Testen)") { viewModel.drainNeedsForTesting() }
                Button("10 Sterne geben (zum Testen)") { viewModel.addStarsForTesting() }
            }
            Button("Spiel zurücksetzen (neues Ei)", role: .destructive) { viewModel.resetGame() }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Zurücksetzen löscht den gesamten Fortschritt.")
        }
    }
}

#Preview("Spiel", traits: .landscapeLeft) {
    GameView(viewModel: LabubuViewModel())
}
