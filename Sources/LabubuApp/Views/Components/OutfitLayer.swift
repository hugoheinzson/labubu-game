import SwiftUI
import UIKit

/// Passende PNGs ersetzen die gezeichneten Teile und Emojis, sobald sie vorhanden sind.
enum OutfitArtwork {
    static func image(for item: OutfitItem) -> UIImage? {
        UIImage(named: "Outfit-\(item.id)", in: .module, compatibleWith: nil)
    }
}

/// Zeichnet die getragenen Kleidungsstücke über Labubu.
/// Positionen sind im selben 300×380-Entwurfsraster wie `DrawnLabubu` angegeben (Ursprung = Mitte).
struct OutfitLayer: View {
    let items: [OutfitItem]

    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / 300, geo.size.height / 380)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                ForEach(items) { item in
                    let place = Self.placement(for: item)
                    garment(item)
                        .frame(width: place.size, height: place.size)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(place.rotation))
                        .position(x: center.x + place.offset.x * scale, y: center.y + place.offset.y * scale)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func garment(_ item: OutfitItem) -> some View {
        if let image = OutfitArtwork.image(for: item) {
            Image(uiImage: image).resizable().scaledToFit()
        } else {
            drawnGarment(item)
        }
    }

    @ViewBuilder
    private func drawnGarment(_ item: OutfitItem) -> some View {
        switch item.id {
        case "mintVest", "roseVest":
            ZStack {
                VestShape()
                    .fill((item.id == "mintVest" ? Color.mint : Color.pink).gradient)
                VestShape().stroke(.white.opacity(0.7), lineWidth: 2)
                Rectangle().fill(.white.opacity(0.65)).frame(width: 2, height: 76).offset(y: 5)
                VStack(spacing: 13) {
                    ForEach(0..<3) { _ in Circle().fill(.white).frame(width: 5, height: 5) }
                }.offset(x: 8, y: 9)
            }
        case "bowtie":
            ZStack {
                Capsule().fill(.indigo).frame(width: 80, height: 7)
                Ellipse().fill(.indigo.gradient).frame(width: 35, height: 32)
                    .rotationEffect(.degrees(20)).offset(x: -17)
                Ellipse().fill(.indigo.gradient).frame(width: 35, height: 32)
                    .rotationEffect(.degrees(-20)).offset(x: 17)
                RoundedRectangle(cornerRadius: 4).fill(.purple).frame(width: 14, height: 25)
            }
        case "scarf":
            ZStack {
                RoundedRectangle(cornerRadius: 9).fill(.orange.gradient)
                    .frame(width: 24, height: 61).rotationEffect(.degrees(-12)).offset(x: 23, y: 23)
                Capsule().fill(.orange.gradient).frame(width: 104, height: 23)
                Capsule().stroke(.white.opacity(0.5), lineWidth: 2).frame(width: 104, height: 23)
            }
        default:
            Text(item.emoji).font(.system(size: Self.placement(for: item).size))
        }
    }

    struct Placement {
        let offset: CGPoint
        let size: CGFloat
        var rotation: Double = 0
    }

    static func placement(for item: OutfitItem) -> Placement {
        switch item.slot {
        case .body:
            return Placement(offset: CGPoint(x: 0, y: 100), size: 112)
        case .head:
            switch item.id {
            case "bow": return Placement(offset: CGPoint(x: 62, y: -105), size: 80, rotation: 20)
            case "flower": return Placement(offset: CGPoint(x: -62, y: -100), size: 70, rotation: -15)
            case "crown": return Placement(offset: CGPoint(x: 0, y: -132), size: 100)
            default: return Placement(offset: CGPoint(x: 0, y: -122), size: 120)
            }
        case .eyes:
            return Placement(offset: CGPoint(x: 0, y: -8), size: 125)
        case .neck:
            let usesArtwork = Artwork.image(.babyLabubu) != nil
            return Placement(offset: CGPoint(x: 0, y: usesArtwork ? 55 : 100), size: item.id == "butterfly" ? 60 : 110)
        case .hand:
            switch item.id {
            case "balloon": return Placement(offset: CGPoint(x: 140, y: 45), size: 100)
            case "wand": return Placement(offset: CGPoint(x: 130, y: 90), size: 75, rotation: -20)
            default: return Placement(offset: CGPoint(x: 128, y: 110), size: 75)
            }
        }
    }
}

/// Schulterpartie und Armausschnitte lassen Kopf, Hände und Füße frei.
private struct VestShape: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGPoint] = [
            .init(x: 0.24, y: 0.08), .init(x: 0.38, y: 0.04), .init(x: 0.5, y: 0.3),
            .init(x: 0.62, y: 0.04), .init(x: 0.76, y: 0.08), .init(x: 0.72, y: 0.32),
            .init(x: 0.89, y: 0.45), .init(x: 0.84, y: 0.94), .init(x: 0.52, y: 0.99),
            .init(x: 0.5, y: 0.93), .init(x: 0.48, y: 0.99), .init(x: 0.16, y: 0.94),
            .init(x: 0.11, y: 0.45), .init(x: 0.28, y: 0.32)
        ]
        var path = Path()
        path.addLines(points.map { CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height) })
        path.closeSubpath()
        return path
    }
}
