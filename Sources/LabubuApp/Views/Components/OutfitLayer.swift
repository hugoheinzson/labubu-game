import SwiftUI

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
                    Text(item.emoji)
                        .font(.system(size: place.size * scale))
                        .rotationEffect(.degrees(place.rotation))
                        .position(x: center.x + place.offset.x * scale, y: center.y + place.offset.y * scale)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                }
            }
        }
        .allowsHitTesting(false)
    }

    struct Placement {
        let offset: CGPoint
        let size: CGFloat
        var rotation: Double = 0
    }

    static func placement(for item: OutfitItem) -> Placement {
        switch item.slot {
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
            return Placement(offset: CGPoint(x: 0, y: 100), size: item.id == "butterfly" ? 60 : 85)
        case .hand:
            switch item.id {
            case "balloon": return Placement(offset: CGPoint(x: 140, y: 45), size: 100)
            case "wand": return Placement(offset: CGPoint(x: 130, y: 90), size: 75, rotation: -20)
            default: return Placement(offset: CGPoint(x: 128, y: 110), size: 75)
            }
        }
    }
}
