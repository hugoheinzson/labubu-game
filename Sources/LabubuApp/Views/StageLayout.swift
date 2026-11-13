import SwiftUI

/// Gemeinsames Layout aller Szenen: großer Bühnenbereich in der Mitte, Leiste unten.
/// Weil Ei- und Labubu-Szene dasselbe Layout nutzen, steht Labubu nach dem Schlüpfen an genau derselben Stelle.
struct StageLayout<Stage: View, Bar: View>: View {
    @ViewBuilder var stage: (CGSize) -> Stage
    @ViewBuilder var bar: () -> Bar

    var body: some View {
        GeometryReader { geo in
            let height = min(geo.size.height * 0.5, geo.size.width * 0.6)
            let size = CGSize(width: height * 0.8, height: height)
            VStack(spacing: 0) {
                Spacer()
                stage(size).frame(width: size.width, height: size.height)
                Spacer()
                bar().frame(height: 100)
                Spacer().frame(height: 48)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
