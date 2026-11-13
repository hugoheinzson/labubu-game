import SwiftUI

/// Einstiegs-View des Spiels. Die eigentliche App (`App/LabubuGameApp.swift`)
/// zeigt nur diese View an, die gesamte Logik lebt im Package.
public struct LabubuRootView: View {
    @StateObject private var viewModel = LabubuViewModel()

    public init() {}

    public var body: some View {
        EggView(viewModel: viewModel)
            .preferredColorScheme(.light)
    }
}
