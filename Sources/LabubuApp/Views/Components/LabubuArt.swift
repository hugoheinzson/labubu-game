import SwiftUI

/// Baby-Labubu: Bild aus `Resources`, falls vorhanden, sonst eine gezeichnete Platzhalter-Figur.
/// Für jede Stimmung kann es ein eigenes Bild geben (`BabyLabubu-hungry.png` …), sonst gilt `BabyLabubu.png`.
struct LabubuArt: View {
    var mood: LabubuMood = .happy
    var chewing = false

    var body: some View {
        if let image = Artwork.labubu(mood: chewing ? .happy : mood) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            DrawnLabubu(mood: mood, chewing: chewing)
        }
    }
}

/// Gezeichnete Platzhalter-Figur (flauschiges Monster mit Hasenohren und Zahnlücken-Grinsen).
/// Entworfen auf 300×380 Punkten und auf die verfügbare Größe skaliert.
struct DrawnLabubu: View {
    var mood: LabubuMood = .happy
    var chewing = false

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
            if mood == .sad && !chewing {
                Teardrop().fill(Color(red: 0.55, green: 0.8, blue: 1)).frame(width: 16, height: 24).offset(x: -48, y: 26)
            }
            cheek(x: -68)
            cheek(x: 68)
            mouth.offset(y: 45)
        }
    }

    private func cheek(x: CGFloat) -> some View {
        Ellipse().fill(pink.opacity(0.7))
            .frame(width: chewing ? 46 : 34, height: chewing ? 30 : 20)
            .offset(x: x, y: 30)
    }

    private func ear(x: CGFloat, angle: Double) -> some View {
        ZStack {
            Capsule().fill(fur).frame(width: 62, height: 160)
            Capsule().fill(pink).frame(width: 30, height: 110).offset(y: -8)
        }
        .rotationEffect(.degrees(angle))
        .offset(x: x, y: -150)
    }

    @ViewBuilder
    private func eye(x: CGFloat) -> some View {
        Group {
            switch mood {
            case .sleeping:
                // Geschlossene Augen: nach unten gebogene Bögen.
                ClosedEye().stroke(mouthColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 30, height: 12)
            case .tired where !chewing:
                // Halb geschlossene Augen mit Lid.
                ZStack(alignment: .top) {
                    Ellipse().fill(.black).frame(width: 30, height: 40)
                        .mask(Rectangle().frame(height: 20).offset(y: 10))
                    Capsule().fill(mouthColor).frame(width: 34, height: 5).offset(y: 18)
                }
                .frame(width: 34, height: 40)
            default:
                ZStack {
                    Ellipse().fill(.black).frame(width: 30, height: 40)
                    Circle().fill(.white).frame(width: 11, height: 11).offset(x: 5, y: -8)
                }
            }
        }
        .offset(x: x, y: -10)
    }

    @ViewBuilder
    private var mouth: some View {
        if chewing {
            Wave().stroke(mouthColor, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .frame(width: 44, height: 10)
        } else {
            switch mood {
            case .happy:
                grin
            case .hungry:
                // Weit offener Mund mit Zunge – „Ich hab Hunger!“
                ZStack(alignment: .top) {
                    Ellipse().fill(mouthColor).frame(width: 64, height: 50)
                    Ellipse().fill(pink).frame(width: 36, height: 18).offset(y: 28)
                    TeethShape(count: 6).fill(.white).frame(width: 52, height: 10).offset(y: 4)
                }
                .frame(width: 64, height: 50)
            case .tired:
                // Gähnen
                Ellipse().fill(mouthColor).frame(width: 30, height: 38)
            case .sad:
                Frown().stroke(mouthColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 18)
            case .sleeping:
                Ellipse().fill(mouthColor).frame(width: 16, height: 12)
            }
        }
    }

    private var grin: some View {
        ZStack(alignment: .top) {
            GrinShape().fill(mouthColor)
            TeethShape(count: 9).fill(.white)
                .frame(height: 12)
        }
        .frame(width: 100, height: 40)
    }
}

private struct ClosedEye: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY), control: CGPoint(x: r.midX, y: r.maxY * 2))
        return p
    }
}

private struct Frown: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.maxY), control: CGPoint(x: r.midX, y: r.minY - r.height))
        return p
    }
}

private struct Wave: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.midY))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.midY), control: CGPoint(x: r.minX + r.width / 4, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.midY), control: CGPoint(x: r.maxX - r.width / 4, y: r.minY))
        return p
    }
}

private struct Teardrop: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.maxY - r.width / 2), control: CGPoint(x: r.maxX, y: r.midY))
        p.addArc(center: CGPoint(x: r.midX, y: r.maxY - r.width / 2), radius: r.width / 2,
                 startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.minY), control: CGPoint(x: r.minX, y: r.midY))
        return p
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

#Preview("Stimmungen") {
    HStack {
        ForEach(LabubuMood.allCases, id: \.self) { mood in
            DrawnLabubu(mood: mood).frame(width: 150, height: 190)
        }
        DrawnLabubu(chewing: true).frame(width: 150, height: 190)
    }
    .padding()
    .background(.pink.opacity(0.3))
}
