import Foundation

/// Wo an Labubu ein Kleidungsstück sitzt. Pro Platz kann genau ein Teil getragen werden.
enum OutfitSlot: String, Codable, CaseIterable {
    case head, eyes, neck, hand
}

struct OutfitItem: Identifiable, Equatable {
    let id: String
    let emoji: String
    let slot: OutfitSlot
    /// Preis in Sternen. 0 = von Anfang an da.
    let price: Int

    /// Alle Teile im Kleiderschrank, in Anzeige-Reihenfolge.
    static let catalog: [OutfitItem] = [
        OutfitItem(id: "bow", emoji: "🎀", slot: .head, price: 0),
        OutfitItem(id: "glasses", emoji: "👓", slot: .eyes, price: 0),
        OutfitItem(id: "flower", emoji: "🌸", slot: .head, price: 1),
        OutfitItem(id: "balloon", emoji: "🎈", slot: .hand, price: 1),
        OutfitItem(id: "sunflower", emoji: "🌻", slot: .hand, price: 1),
        OutfitItem(id: "cap", emoji: "🧢", slot: .head, price: 2),
        OutfitItem(id: "sunglasses", emoji: "🕶️", slot: .eyes, price: 2),
        OutfitItem(id: "scarf", emoji: "🧣", slot: .neck, price: 2),
        OutfitItem(id: "lollipop", emoji: "🍭", slot: .hand, price: 2),
        OutfitItem(id: "butterfly", emoji: "🦋", slot: .neck, price: 3),
        OutfitItem(id: "tophat", emoji: "🎩", slot: .head, price: 3),
        OutfitItem(id: "teddy", emoji: "🧸", slot: .hand, price: 3),
        OutfitItem(id: "wand", emoji: "🪄", slot: .hand, price: 4),
        OutfitItem(id: "crown", emoji: "👑", slot: .head, price: 5),
    ]

    static func find(_ id: String) -> OutfitItem? {
        catalog.first { $0.id == id }
    }

    static var freeItemIDs: Set<String> {
        Set(catalog.filter { $0.price == 0 }.map(\.id))
    }
}
