import SwiftUI

@main
struct LabubuApp: App {
    @StateObject private var viewModel = LabubuViewModel()

    var body: some Scene {
        WindowGroup {
            EggView(viewModel: viewModel)
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 1000, height: 750)
    }
}
