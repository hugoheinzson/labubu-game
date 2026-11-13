import UIKit

/// Zentrale Stelle für alle Bild-Dateien in `Resources`. Fehlt eine Datei, liefert `image` nil
/// und die Views zeigen ihre gezeichnete Platzhalter-Version.
enum Artwork: String {
    case egg = "EggClosed"
    case babyLabubu = "BabyLabubu"

    static func image(_ art: Artwork) -> UIImage? {
        UIImage(named: art.rawValue, in: .module, compatibleWith: nil)
    }
}
