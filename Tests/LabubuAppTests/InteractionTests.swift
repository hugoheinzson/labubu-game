import Foundation
import CoreGraphics
import Testing
@testable import LabubuApp

struct InteractionTests {
    @Test func newEggPreservesCollectionAndClearsSleepAndProgress() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var state = LabubuState()
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching(at: now)
        let vest = OutfitItem.find("mintVest")!
        _ = state.buy(vest)
        state.wear(vest)
        state.sleep(at: now)
        let stars = state.stars
        state.startNewEgg()
        #expect(state.stage == .egg)
        #expect(state.eggTaps == 0)
        #expect(!state.isSleeping)
        #expect(state.stars == stars)
        #expect(state.owns(vest))
        #expect(state.isWearing(vest))
        let restored = try JSONDecoder().decode(LabubuState.self, from: JSONEncoder().encode(state))
        #expect(restored == state)
    }

    @Test @MainActor func restartingAnEggAlsoRestartsItsSceneSession() {
        let store = GameStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("state.json"))
        let vm = LabubuViewModel(store: store, tickInterval: nil)
        let firstSession = vm.eggSessionID
        vm.tapEgg()
        vm.startNewEgg()
        #expect(vm.eggSessionID != firstSession)
        #expect(vm.state.eggTaps == 0)
        #expect(store.load()?.eggTaps == 0)
    }

    @Test func nestHoldsSmallMovementsButReleasesOnTilt() {
        var egg = EggPhysics()
        egg.limits = CGSize(width: 200, height: 100)
        egg.step(tilt: CGVector(dx: 0.05, dy: 0), dt: 1.0 / 30)
        #expect(egg.isDocked)
        #expect(egg.position == .zero)
        egg.step(tilt: CGVector(dx: 0.5, dy: 0), dt: 1.0 / 30)
        #expect(!egg.isDocked)
        #expect(egg.position.x > 0)
    }

    @Test func calmTabletStopsEggAndEdgesKeepItVisible() {
        var egg = EggPhysics()
        egg.limits = CGSize(width: 100, height: 50)
        for _ in 0..<300 { egg.step(tilt: CGVector(dx: 1, dy: -1), dt: 1.0 / 30) }
        #expect(abs(egg.position.x) <= 100)
        #expect(abs(egg.position.y) <= 50)
        for _ in 0..<120 { egg.step(tilt: .zero, dt: 1.0 / 30) }
        #expect(egg.velocity == .zero)
        #expect(!egg.isDocked, "Ruhig liegen reicht nicht: zurück ins Nest ziehen")
    }

    @Test func onlyDroppingNearNestDocksEgg() {
        var egg = EggPhysics()
        egg.limits = CGSize(width: 200, height: 100)
        egg.drag(to: CGPoint(x: 150, y: 0))
        let outside = egg.release(nestRadius: 50)
        #expect(!outside)
        egg.drag(to: CGPoint(x: 20, y: 20))
        let inside = egg.release(nestRadius: 50)
        #expect(inside)
        #expect(egg.isDocked)
        #expect(egg.position == .zero)
        #expect(egg.velocity == .zero)
    }

    @Test func dropOnVisibleNestBowlAndResizeAreHandled() {
        var egg = EggPhysics()
        egg.limits = CGSize(width: 200, height: 300)
        egg.drag(to: CGPoint(x: 10, y: 180))
        let docked = egg.release(nestRadius: 60, nestDepth: 200)
        #expect(docked)
        egg.drag(to: CGPoint(x: 180, y: 280))
        egg.resize(to: CGSize(width: 50, height: 30))
        #expect(abs(egg.position.x) <= 50)
        #expect(abs(egg.position.y) <= 30)
    }

    @Test func foodMustHitMouthRatherThanForeheadOrBelly() {
        let mouth = CGPoint(x: 300, y: 400)
        let radius = CGSize(width: 55, height: 35)
        #expect(FeedingTarget.contains(mouth, mouth: mouth, radius: radius))
        #expect(FeedingTarget.contains(CGPoint(x: 325, y: 415), mouth: mouth, radius: radius))
        #expect(!FeedingTarget.contains(CGPoint(x: 300, y: 300), mouth: mouth, radius: radius))
        #expect(!FeedingTarget.contains(CGPoint(x: 300, y: 500), mouth: mouth, radius: radius))
        #expect(!FeedingTarget.contains(mouth, mouth: mouth, radius: .zero))
    }

    @Test func playingMakesTiredThenSleepAllowsPlayingAgain() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var state = LabubuState()
        let playedAsEgg = state.play(at: now)
        #expect(!playedAsEgg)
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching(at: now)
        let before = state.needs
        let first = state.play(at: now)
        #expect(first)
        #expect(state.needs.energy < before.energy)
        #expect(state.needs.fun >= before.fun)
        #expect(state.needs.hunger < before.hunger)
        for _ in 0..<10 { state.play(at: now) }
        #expect(state.needs.energy >= 0)
        let exhausted = state.play(at: now)
        #expect(!exhausted)
        let restored = try JSONDecoder().decode(LabubuState.self, from: JSONEncoder().encode(state))
        #expect(restored.needs == state.needs)
        state.sleep(at: now)
        let whileSleeping = state.play(at: now)
        #expect(!whileSleeping)
        state.wakeUp(at: now.addingTimeInterval(Needs.sleepRefillDuration))
        let afterSleep = state.play(at: now.addingTimeInterval(Needs.sleepRefillDuration))
        #expect(afterSleep)
    }
}
