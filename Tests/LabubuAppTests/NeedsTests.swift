import Foundation
import Testing
@testable import LabubuApp

struct NeedsTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    private func hatched() -> LabubuState {
        var state = LabubuState()
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching(at: start)
        return state
    }

    @Test func newbornIsHungryAndWantsFood() {
        let state = hatched()
        #expect(state.mood == .hungry)
        #expect(state.wish == .hunger)
    }

    @Test func needsDecayWhileAppIsClosed() {
        var state = hatched()
        state.advanceNeeds(to: start.addingTimeInterval(2 * 3600))
        #expect(state.needs.fun < Needs.newborn.fun)
        #expect(state.needs.energy < Needs.newborn.energy)
        // Nach einem ganzen Tag ist alles leer, aber nie negativ.
        state.advanceNeeds(to: start.addingTimeInterval(24 * 3600))
        #expect(state.needs == Needs(hunger: 0, fun: 0, energy: 0))
    }

    @Test func feedingFillsHungerUntilFull() {
        var state = hatched()
        let firstMeal = state.feed(at: start)
        #expect(firstMeal)
        #expect(state.needs.hunger > Needs.newborn.hunger)
        while state.feed(at: start) {}
        #expect(state.needs.hunger >= 0.95)
        let refused = !state.feed(at: start)
        #expect(refused, "satt – Labubu lehnt ab")
        #expect(state.mood == .happy)
    }

    @Test func sleepingRefillsEnergyAndBlocksFeeding() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        state.sleep(at: start)
        #expect(state.mood == .sleeping)
        let fedWhileSleeping = state.feed(at: start)
        #expect(!fedWhileSleeping)
        state.advanceNeeds(to: start.addingTimeInterval(Needs.sleepRefillDuration))
        #expect(state.needs.energy == 1)
        // Hunger sinkt im Schlaf langsamer als wach.
        var awake = hatched()
        awake.drainNeedsForTesting(at: start)
        awake.advanceNeeds(to: start.addingTimeInterval(3600))
        var asleep = hatched()
        asleep.drainNeedsForTesting(at: start)
        asleep.sleep(at: start)
        asleep.advanceNeeds(to: start.addingTimeInterval(3600))
        #expect(asleep.needs.hunger > awake.needs.hunger)
        state.wakeUp(at: start.addingTimeInterval(60))
        #expect(!state.isSleeping)
    }

    @Test func pettingMakesHappy() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        let before = state.needs.fun
        state.pet(at: start)
        #expect(state.needs.fun > before)
    }

    @Test func moodPriorityIsHungerThenTirednessThenFun() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        #expect(state.mood == .hungry)
        while state.feed(at: start) {}
        #expect(state.mood == .tired)
    }

    @Test func nothingHappensBeforeHatching() {
        var state = LabubuState()
        let fedEgg = state.feed(at: start)
        #expect(!fedEgg)
        state.sleep(at: start)
        #expect(!state.isSleeping)
    }

    @Test func weekOneSaveStillLoads() throws {
        let json = #"{"eggTaps":18,"hatchedAt":800000000}"#
        let state = try JSONDecoder().decode(LabubuState.self, from: Data(json.utf8))
        #expect(state.stage == .hatched)
        #expect(state.needs == .newborn)
        #expect(state.needsUpdatedAt == state.hatchedAt)
    }
}
