import SwiftUI

/// Einstiegs-View des Spiels. Die eigentliche App (`App/LabubuGameApp.swift`)
/// zeigt nur diese View an, die gesamte Logik lebt im Package.
public struct LabubuRootView: View {
    @StateObject private var viewModel = LabubuViewModel()
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some View {
        GameView(viewModel: viewModel)
            .preferredColorScheme(.light)
            .persistentSystemOverlays(.hidden)
            .statusBarHidden()
            .onChange(of: scenePhase) { _, phase in
                // Zurück in der App: Bedürfnisse auf die Zeit fortschreiben, in der sie geschlossen war.
                if phase == .active { viewModel.tick() }
            }
    }
}
