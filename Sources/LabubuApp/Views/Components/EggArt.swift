import SwiftUI

/// Eiform: unten breiter als oben.
struct EggShape: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w / 2, y: y))
        p.addCurve(to: CGPoint(x: x + w, y: y + h * 0.62),
                   control1: CGPoint(x: x + w * 0.82, y: y),
                   control2: CGPoint(x: x + w, y: y + h * 0.33))
        p.addCurve(to: CGPoint(x: x + w / 2, y: y + h),
                   control1: CGPoint(x: x + w, y: y + h * 0.86),
                   control2: CGPoint(x: x + w * 0.78, y: y + h))
        p.addCurve(to: CGPoint(x: x, y: y + h * 0.62),
                   control1: CGPoint(x: x + w * 0.22, y: y + h),
                   control2: CGPoint(x: x, y: y + h * 0.86))
        p.addCurve(to: CGPoint(x: x + w / 2, y: y),
                   control1: CGPoint(x: x, y: y + h * 0.33),
                   control2: CGPoint(x: x + w * 0.18, y: y))
        p.closeSubpath()
        return p
    }
}

/// Zickzack-Linie, an der das Ei beim Schlüpfen auseinanderbricht (relative Koordinaten 0…1).
private let splitLine: [CGPoint] = [
    CGPoint(x: -0.05, y: 0.47), CGPoint(x: 0.10, y: 0.42), CGPoint(x: 0.22, y: 0.50),
    CGPoint(x: 0.34, y: 0.41), CGPoint(x: 0.46, y: 0.50), CGPoint(x: 0.58, y: 0.41),
    CGPoint(x: 0.70, y: 0.50), CGPoint(x: 0.82, y: 0.42), CGPoint(x: 0.94, y: 0.49),
    CGPoint(x: 1.05, y: 0.45),
]

/// Obere oder untere Ei-Hälfte, getrennt an der Zickzack-Linie.
struct EggHalf: Shape {
    let top: Bool

    func path(in r: CGRect) -> Path {
        func pt(_ p: CGPoint) -> CGPoint { CGPoint(x: r.minX + p.x * r.width, y: r.minY + p.y * r.height) }
        var p = Path()
        let edgeY = top ? r.minY - r.height : r.maxY + r.height
        p.move(to: CGPoint(x: r.minX - r.width, y: edgeY))
        p.addLine(to: CGPoint(x: r.minX - r.width, y: pt(splitLine[0]).y))
        splitLine.forEach { p.addLine(to: pt($0)) }
        p.addLine(to: CGPoint(x: r.maxX + r.width, y: pt(splitLine[splitLine.count - 1]).y))
        p.addLine(to: CGPoint(x: r.maxX + r.width, y: edgeY))
        p.closeSubpath()
        return p
    }
}

/// Risse im Ei, Stufe 1…3. Stufe 3 entspricht der Bruchlinie.
struct CrackLines: Shape {
    let level: Int

    private static let cracks: [[CGPoint]] = [
        [CGPoint(x: 0.30, y: 0.30), CGPoint(x: 0.37, y: 0.36), CGPoint(x: 0.32, y: 0.42), CGPoint(x: 0.40, y: 0.47)],
        [CGPoint(x: 0.66, y: 0.24), CGPoint(x: 0.60, y: 0.31), CGPoint(x: 0.68, y: 0.37), CGPoint(x: 0.61, y: 0.44),
         CGPoint(x: 0.66, y: 0.49)],
        Array(splitLine.dropFirst().dropLast()),
    ]

    func path(in r: CGRect) -> Path {
        var p = Path()
        for crack in Self.cracks.prefix(level) {
            let pts = crack.map { CGPoint(x: r.minX + $0.x * r.width, y: r.minY + $0.y * r.height) }
            p.addLines(pts)
        }
        return p
    }
}

/// Gezeichnetes Pastell-Ei mit Punkten. Wird durch `EggClosed.png` ersetzt, sobald es die Grafik gibt.
struct DrawnEgg: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                EggShape().fill(
                    LinearGradient(colors: [Color(red: 1, green: 0.97, blue: 0.92), Color(red: 1, green: 0.86, blue: 0.9)],
                                   startPoint: .top, endPoint: .bottom)
                )
                Group {
                    spot(.mint, size: w * 0.20, x: w * 0.28, y: h * 0.62)
                    spot(.purple.opacity(0.35), size: w * 0.14, x: w * 0.70, y: h * 0.70)
                    spot(.cyan.opacity(0.35), size: w * 0.12, x: w * 0.62, y: h * 0.20)
                    spot(.orange.opacity(0.35), size: w * 0.10, x: w * 0.25, y: h * 0.25)
                    spot(.pink.opacity(0.45), size: w * 0.16, x: w * 0.52, y: h * 0.86)
                }
                .clipShape(EggShape())
                Ellipse()
                    .fill(.white.opacity(0.6))
                    .frame(width: w * 0.18, height: h * 0.22)
                    .rotationEffect(.degrees(-20))
                    .position(x: w * 0.30, y: h * 0.22)
                    .blur(radius: 4)
                EggShape().stroke(.white.opacity(0.8), lineWidth: 3)
            }
        }
    }

    private func spot(_ color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle().fill(color.opacity(0.5)).frame(width: size, height: size).position(x: x, y: y)
    }
}

/// Ei-Grafik (Bild oder gezeichnet) inklusive Rissen.
struct EggArt: View {
    let crackLevel: Int

    var body: some View {
        ZStack {
            if let image = Artwork.image(.egg) {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                DrawnEgg()
            }
            CrackLines(level: crackLevel)
                .stroke(Color(red: 0.35, green: 0.22, blue: 0.2),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        }
    }
}
