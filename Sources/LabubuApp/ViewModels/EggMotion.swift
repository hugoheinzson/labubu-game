import Combine
import CoreMotion
import UIKit

@MainActor
final class EggMotion: ObservableObject {
    @Published private(set) var physics = EggPhysics()
    private let manager = CMMotionManager()
    private var baseline: CGVector?
    private var orientation: UIInterfaceOrientation = .unknown
    private var lastTimestamp: TimeInterval?
    private var dragStart: CGPoint?

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        baseline = nil
        lastTimestamp = nil
        manager.deviceMotionUpdateInterval = 1.0 / 30
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }
            // Updates kommen ausdrücklich auf die Hauptwarteschlange.
            MainActor.assumeIsolated { self?.update(motion) }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        baseline = nil
        lastTimestamp = nil
        dragStart = nil
    }

    func setLimits(_ limits: CGSize) { physics.resize(to: limits) }
    func dock() { physics.dock() }

    func drag(_ translation: CGSize) {
        if dragStart == nil { dragStart = physics.position }
        guard let dragStart else { return }
        physics.drag(to: CGPoint(x: dragStart.x + translation.width, y: dragStart.y + translation.height))
    }

    func release(nestRadius: CGFloat, nestDepth: CGFloat) -> Bool {
        dragStart = nil
        return physics.release(nestRadius: nestRadius, nestDepth: nestDepth)
    }

    private func update(_ motion: CMDeviceMotion) {
        guard dragStart == nil else { return }
        let current = (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)?.interfaceOrientation ?? .portrait
        if current != orientation {
            orientation = current
            baseline = nil
        }
        let g = motion.gravity
        let gravity: CGVector
        switch current {
        case .landscapeLeft: gravity = CGVector(dx: -g.y, dy: -g.x)
        case .landscapeRight: gravity = CGVector(dx: g.y, dy: g.x)
        case .portraitUpsideDown: gravity = CGVector(dx: -g.x, dy: g.y)
        default: gravity = CGVector(dx: g.x, dy: -g.y)
        }
        if baseline == nil { baseline = gravity }
        let dt = lastTimestamp.map { motion.timestamp - $0 } ?? 1.0 / 30
        lastTimestamp = motion.timestamp
        guard let baseline else { return }
        let r = motion.rotationRate, a = motion.userAcceleration
        let moving = sqrt(r.x * r.x + r.y * r.y + r.z * r.z) > 0.06
            || sqrt(a.x * a.x + a.y * a.y + a.z * a.z) > 0.045
        // In jeder ruhig gehaltenen Haltung bremsen, nicht erst beim flachen Ablegen.
        let tilt = moving ? CGVector(dx: gravity.dx - baseline.dx, dy: gravity.dy - baseline.dy) : .zero
        physics.step(tilt: tilt, dt: dt)
    }
}
