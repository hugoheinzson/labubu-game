import SwiftUI

/// Baby-Labubu: Bild `BabyLabubu.png`, falls vorhanden, sonst eine gezeichnete Platzhalter-Figur.
struct LabubuArt: View {
    var body: some View {
        if let image = Artwork.image(.babyLabubu) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            DrawnLabubu()
        }
    }
}

/// Gezeichnete Platzhalter-Figur (flauschiges Monster mit Hasenohren und Zahnlücken-Grinsen).
/// Entworfen auf 300×380 Punkten und auf die verfügbare Größe skaliert.
struct DrawnLabubu: View {
    private let fur = Color(red: 0.96, green: 0.84, blue: 0.74)
    private let furDark = Color(red: 0.86, green: 0.70, blue: 0.60)
    private let face = Color(red: 1.0, green: 0.95, blue: 0.90)
    private let pink = Color(red: 1.0, green: 0.68, blue: 0.75)
    private let mouthColor = Color(red: 0.45, green: 0.2, blue: 0.22)

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / 300, geo.size.height / 380)
            figure
                .frame(width: 300, height: 380)
                .scaleEffect(scale)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var figure: some View {
        ZStack {
            ear(x: -58, angle: -14)
            ear(x: 58, angle: 14)
            // Füße und Körper
            Ellipse().fill(furDark).frame(width: 70, height: 40).offset(x: -55, y: 168)
            Ellipse().fill(furDark).frame(width: 70, height: 40).offset(x: 55, y: 168)
            Ellipse().fill(fur).frame(width: 210, height: 170).offset(y: 105)
            Capsule().fill(fur).frame(width: 40, height: 90).rotationEffect(.degrees(25)).offset(x: -105, y: 95)
            Capsule().fill(fur).frame(width: 40, height: 90).rotationEffect(.degrees(-25)).offset(x: 105, y: 95)
            // Kopf
            Circle().fill(fur).frame(width: 230, height: 230).offset(y: -15)
            Ellipse().fill(face).frame(width: 175, height: 140).offset(y: 5)
            eye(x: -40)
            eye(x: 40)
            Ellipse().fill(pink.opacity(0.7)).frame(width: 34, height: 20).offset(x: -68, y: 30)
            Ellipse().fill(pink.opacity(0.7)).frame(width: 34, height: 20).offset(x: 68, y: 30)
            mouth.offset(y: 45)
        }
    }

    private func ear(x: CGFloat, angle: Double) -> some View {
        ZStack {
            Capsule().fill(fur).frame(width: 62, height: 160)
            Capsule().fill(pink).frame(width: 30, height: 110).offset(y: -8)
        }
        .rotationEffect(.degrees(angle))
        .offset(x: x, y: -150)
    }

    private func eye(x: CGFloat) -> some View {
        ZStack {
            Ellipse().fill(.black).frame(width: 30, height: 40)
            Circle().fill(.white).frame(width: 11, height: 11).offset(x: 5, y: -8)
        }
        .offset(x: x, y: -10)
    }

    private var mouth: some View {
        ZStack(alignment: .top) {
            GrinShape().fill(mouthColor)
            TeethShape(count: 9).fill(.white)
                .frame(height: 12)
        }
        .frame(width: 100, height: 40)
    }
}

private struct GrinShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.minY), control: CGPoint(x: r.midX, y: r.maxY * 1.6))
        return p
    }
}

/// Reihe kleiner spitzer Zähne an der Oberkante des Mundes.
private struct TeethShape: Shape {
    let count: Int

    func path(in r: CGRect) -> Path {
        var p = Path()
        let inset = r.width * 0.08
        let w = (r.width - 2 * inset) / CGFloat(count)
        for i in 0..<count {
            let x = r.minX + inset + CGFloat(i) * w
            p.move(to: CGPoint(x: x, y: r.minY))
            p.addLine(to: CGPoint(x: x + w, y: r.minY))
            p.addLine(to: CGPoint(x: x + w / 2, y: r.maxY))
            p.closeSubpath()
        }
        return p
    }
}

#Preview {
    DrawnLabubu().frame(width: 300, height: 380).padding().background(.pink.opacity(0.3))
}
