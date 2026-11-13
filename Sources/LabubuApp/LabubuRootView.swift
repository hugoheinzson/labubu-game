import SwiftUI

/// Einstiegs-View des Spiels. Die eigentliche App (`App/LabubuGameApp.swift`)
/// zeigt nur diese View an, die gesamte Logik lebt im Package.
public struct LabubuRootView: View {
    @StateObject private var viewModel = LabubuViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("audioMuted") private var audioMuted = false

    public init() {}

    public var body: some View {
        GameView(viewModel: viewModel)
            .preferredColorScheme(.light)
            .persistentSystemOverlays(.hidden)
            .statusBarHidden()
            .onAppear(perform: updateMusic)
            .onChange(of: musicEnabled) { _, _ in updateMusic() }
            .onChange(of: audioMuted) { _, _ in updateMusic() }
            .onChange(of: viewModel.state.isSleeping) { _, _ in updateMusic() }
            .onChange(of: scenePhase) { _, phase in
                // Zurück in der App: Bedürfnisse auf die Zeit fortschreiben, in der sie geschlossen war.
                if phase == .active { viewModel.tick() }
                updateMusic()
            }
    }

    private func updateMusic() {
        if audioMuted { SoundPlayer.shared.stopEffects() }
        SoundPlayer.shared.updateMusic(enabled: musicEnabled && !audioMuted,
                                       sleeping: viewModel.state.isSleeping,
                                       active: scenePhase == .active)
    }
}
