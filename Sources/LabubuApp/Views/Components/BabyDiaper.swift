import SwiftUI
import UIKit

/// Kleine Stoffwindel im selben Bildraster wie die freigegebene Labubu-Grafik.
/// Sie verschwindet allmählich, wenn aus dem Baby ein größeres Labubu wird.
struct BabyDiaper: View {
    var growthProgress: Double

    private var visibility: Double {
        min(1, max(0, (0.4 - growthProgress) / 0.1))
    }

    var body: some View {
        GeometryReader { geometry in
            let image = UIImage(named: "BabyDiaper", in: .module, compatibleWith: nil)
            // Die PNG hat einen kleinen transparenten Rand und ein Seitenverhältnis von 2:1.
            // Etwas mehr Platz erhält ihre sichtbare Taillenbreite und lässt die Füße frei.
            let size = CGSize(width: geometry.size.width * (image == nil ? 0.38 : 0.43),
                              height: geometry.size.height * (image == nil ? 0.13 : 0.17))
            Group {
                if let image {
                    Image(uiImage: image).resizable().scaledToFit()
                } else {
                    drawnDiaper(size: size)
                }
            }
            .frame(width: size.width, height: size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height * (image == nil ? 0.86 : 0.85))
        }
        .opacity(visibility)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawnDiaper(size: CGSize) -> some View {
        ZStack {
            DiaperShape()
                .fill(LinearGradient(colors: [.white, Color(red: 0.91, green: 0.98, blue: 0.97)],
                                     startPoint: .top, endPoint: .bottom))
            DiaperShape().stroke(Color.mint.opacity(0.65), lineWidth: 1.5)
            Capsule()
                .fill(Color(red: 0.7, green: 0.91, blue: 0.86))
                .frame(width: size.width * 0.94, height: size.height * 0.18)
                .offset(y: -size.height * 0.36)
            HStack {
                RoundedRectangle(cornerRadius: 3).fill(.white)
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 3).fill(.white)
            }
            .frame(width: size.width * 0.82, height: size.height * 0.17)
            .offset(y: -size.height * 0.25)
            Image(systemName: "heart.fill")
                .font(.system(size: size.height * 0.23))
                .foregroundStyle(Color.mint.opacity(0.75))
                .offset(y: size.height * 0.02)
        }
    }
}

private struct DiaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: point(0.05, 0.08))
        path.addQuadCurve(to: point(0.95, 0.08), control: point(0.5, -0.04))
        path.addCurve(to: point(0.75, 0.7), control1: point(1.02, 0.4), control2: point(0.82, 0.44))
        path.addQuadCurve(to: point(0.5, 0.98), control: point(0.71, 1.02))
        path.addQuadCurve(to: point(0.25, 0.7), control: point(0.29, 1.02))
        path.addCurve(to: point(0.05, 0.08), control1: point(0.18, 0.44), control2: point(-0.02, 0.4))
        path.closeSubpath()
        return path
    }
}

#Preview("Baby-Windel") {
    ZStack {
        LabubuArt()
        BabyDiaper(growthProgress: 0)
    }
    .frame(width: 300, height: 375)
    .padding(40)
    .background(.pink.opacity(0.2))
}
