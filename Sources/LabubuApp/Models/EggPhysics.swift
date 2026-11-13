import Foundation
import CoreGraphics

/// Kleine, deterministische Rollsimulation. Positionen relativ zur Nestmitte in Punkten.
struct EggPhysics {
    private(set) var position = CGPoint.zero
    private(set) var velocity = CGVector.zero
    private(set) var isDocked = true
    var limits = CGSize.zero

    mutating func step(tilt: CGVector, dt: Double) {
        let dt = min(0.05, max(0, dt))
        let strength = hypot(tilt.dx, tilt.dy)
        if isDocked {
            guard strength > 0.13 else { return }
            isDocked = false
        }
        let x = abs(tilt.dx) < 0.035 ? 0 : tilt.dx
        let y = abs(tilt.dy) < 0.035 ? 0 : tilt.dy
        let damping = exp(-6 * dt)
        velocity.dx = (velocity.dx + x * 1500 * dt) * damping
        velocity.dy = (velocity.dy + y * 1500 * dt) * damping
        if strength < 0.05 && hypot(velocity.dx, velocity.dy) < 4 { velocity = .zero }
        position.x += velocity.dx * dt
        position.y += velocity.dy * dt
        constrain()
    }

    mutating func drag(to point: CGPoint) {
        isDocked = false
        position = point
        velocity = .zero
        constrain()
    }

    @discardableResult
    mutating func release(nestRadius: CGFloat, nestDepth: CGFloat = 0) -> Bool {
        // Auch direkt auf die sichtbare Nestschale unter der Ei-Mitte ablegen dürfen.
        let y = position.y > 0 ? max(0, position.y - nestDepth) : position.y
        if hypot(position.x, y) <= nestRadius {
            dock()
            return true
        }
        return false
    }

    mutating func dock() {
        position = .zero
        velocity = .zero
        isDocked = true
    }

    mutating func resize(to newLimits: CGSize) {
        limits = newLimits
        constrain()
    }

    private mutating func constrain() {
        let x = max(0, limits.width), y = max(0, limits.height)
        if abs(position.x) > x {
            position.x = min(x, max(-x, position.x))
            velocity.dx *= -0.18
        }
        if abs(position.y) > y {
            position.y = min(y, max(-y, position.y))
            velocity.dy *= -0.18
        }
    }
}
