import Foundation
import Testing
@testable import LabubuApp

struct GrowthTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    private func hatched() -> LabubuState {
        var state = LabubuState()
        state.selectEgg(.mint)
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching(at: start)
        return state
    }

    @Test func freshSelectionAndChosenEggSurviveSaving() throws {
        var state = LabubuState()
        #expect(state.chosenEgg == nil)
        let pending = try JSONDecoder().decode(LabubuState.self, from: JSONEncoder().encode(state))
        #expect(pending.chosenEgg == nil, "Eine noch offene Auswahl darf nach dem Laden nicht verschwinden")
        state.selectEgg(.rose)
        let selected = try JSONDecoder().decode(LabubuState.self, from: JSONEncoder().encode(state))
        #expect(selected.chosenEgg == .rose)
        state.tapEgg()
        state.selectEgg(.mint)
        #expect(state.chosenEgg == .rose, "Ein bereits gewärmtes Ei wechselt nicht seine Farbe")
    }

    @Test func legacySaveKeepsPlayingAndStartsWithBabyGrowth() throws {
        let json = #"{"eggTaps":18,"hatchedAt":800000000}"#
        let state = try JSONDecoder().decode(LabubuState.self, from: Data(json.utf8))
        #expect(state.chosenEgg == .classic)
        #expect(state.growthProgress == 0)
        #expect(state.isBaby)
        #expect(state.growthScale == 0.6)
    }

    @Test func onlyAcceptedFoodGrowsBaby() {
        var state = hatched()
        #expect(state.growthProgress == 0)
        let accepted = state.feed(at: start)
        #expect(accepted)
        #expect(state.growthProgress == LabubuState.growthPerMeal)
        #expect(state.growthScale > 0.6)
        while state.feed(at: start) {}
        let full = state.growthProgress
        let rejected = state.feed(at: start)
        #expect(!rejected)
        #expect(state.growthProgress == full)
        state.advanceNeeds(to: start.addingTimeInterval(60))
        #expect(state.growthProgress == full, "Wach herumstehen alleine lässt nicht wachsen")
    }

    @Test func sleepGrowthTracksRecoveredEnergyWithoutDoubleCounting() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        state.sleep(at: start)
        state.advanceNeeds(to: start.addingTimeInterval(15))
        let halfRest = state.growthProgress
        #expect(abs(halfRest - 0.5 * LabubuState.growthPerRecoveredEnergy) < 0.000001)
        state.advanceNeeds(to: start.addingTimeInterval(15))
        #expect(state.growthProgress == halfRest)
        state.advanceNeeds(to: start.addingTimeInterval(60))
        let fullRest = state.growthProgress
        #expect(abs(fullRest - 0.85 * LabubuState.growthPerRecoveredEnergy) < 0.000001)
        state.advanceNeeds(to: start.addingTimeInterval(3600))
        #expect(state.growthProgress == fullRest, "Ein ausgeschlafenes Baby wächst nicht endlos weiter")
        state.wakeUp(at: start.addingTimeInterval(3600))
        for _ in 0..<10 {
            state.sleep(at: start.addingTimeInterval(3600))
            state.wakeUp(at: start.addingTimeInterval(3600))
        }
        #expect(state.growthProgress == fullRest, "Lichtschalter-Spam erzeugt kein Wachstum")
    }

    @Test func sleepingGrowthSurvivesAnOfflineReload() throws {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        state.sleep(at: start)
        state.advanceNeeds(to: start.addingTimeInterval(10))
        let saved = try JSONEncoder().encode(state)
        var loaded = try JSONDecoder().decode(LabubuState.self, from: saved)
        loaded.advanceNeeds(to: start.addingTimeInterval(30))
        state.advanceNeeds(to: start.addingTimeInterval(30))
        #expect(loaded == state)
        #expect(loaded.growthProgress > 0)
    }

    @Test func growthIsBoundedAndNewEggStartsSmallWithoutLosingCollection() throws {
        var state = hatched()
        let vest = OutfitItem.find("mintVest")!
        _ = state.buy(vest)
        state.wear(vest)
        for _ in 0..<30 {
            state.drainNeedsForTesting(at: start)
            _ = state.feed(at: start)
            state.sleep(at: start)
            state.wakeUp(at: start.addingTimeInterval(60))
        }
        #expect(state.growthProgress == 1)
        #expect(state.growthScale == 1)
        #expect(!state.isBaby)
        let stars = state.stars
        state.startNewEgg()
        #expect(state.chosenEgg == nil)
        #expect(state.growthProgress == 0)
        #expect(state.isBaby)
        #expect(state.stars == stars)
        #expect(state.owns(vest))
        #expect(state.isWearing(vest))
        let loaded = try JSONDecoder().decode(LabubuState.self, from: JSONEncoder().encode(state))
        #expect(loaded == state)
    }
}
