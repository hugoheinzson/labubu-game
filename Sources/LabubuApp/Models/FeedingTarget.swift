import Foundation
import CoreGraphics

enum FeedingTarget {
    static func contains(_ point: CGPoint, mouth: CGPoint, radius: CGSize) -> Bool {
        guard radius.width > 0, radius.height > 0 else { return false }
        let x = (point.x - mouth.x) / radius.width
        let y = (point.y - mouth.y) / radius.height
        return x * x + y * y <= 1
    }
}
