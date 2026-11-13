import SwiftUI

/// Rahmen um alle Szenen: Hintergrund, Szenenwechsel und versteckter Eltern-Bereich.
struct GameView: View {
    @ObservedObject var viewModel: LabubuViewModel
    @State private var showParentMenu = false

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
                    .transition(.opacity)
            case .hatched:
                RoomScene(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: viewModel.state.stage == .hatched)
        .overlay(alignment: .topTrailing) { parentGate }
        .confirmationDialog("Eltern-Bereich", isPresented: $showParentMenu, titleVisibility: .visible) {
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

    /// Unsichtbare Ecke oben rechts: 3 Sekunden gedrückt halten öffnet den Eltern-Bereich.
    private var parentGate: some View {
        Color.clear
            .frame(width: 100, height: 100)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 3) { showParentMenu = true }
    }
}

#Preview("Spiel", traits: .landscapeLeft) {
    GameView(viewModel: LabubuViewModel())
}
