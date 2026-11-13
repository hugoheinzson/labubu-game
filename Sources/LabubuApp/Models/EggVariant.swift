import Foundation

/// Drei gleichwertige Start-Eier. Die Farbe ändert nicht die Pflege-Regeln.
enum EggVariant: String, Codable, CaseIterable, Identifiable {
    case classic, rose, mint

    var id: String { rawValue }
}
