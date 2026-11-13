import Foundation
import Testing
@testable import LabubuApp

struct StarsAndWardrobeTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    private func hatched() -> LabubuState {
        var state = LabubuState()
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching(at: start)
        return state
    }

    private func item(_ id: String) -> OutfitItem { OutfitItem.find(id)! }

    @Test func hatchingGivesStartingStars() {
        #expect(hatched().stars == LabubuState.hatchBonusStars)
        #expect(LabubuState().stars == 0)
    }

    @Test func everyMealEarnsAStar() {
        var state = hatched()
        let before = state.stars
        _ = state.feed(at: start)
        #expect(state.stars == before + LabubuState.starsPerMeal)
    }

    @Test func refusedMealEarnsNothing() {
        var state = hatched()
        while state.feed(at: start) {}
        let before = state.stars
        _ = state.feed(at: start)
        #expect(state.stars == before)
    }

    @Test func pettingEarnsAStarOnlyWhileNeeded() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        let before = state.stars
        for _ in 0..<LabubuState.petsPerStar { state.pet(at: start) }
        #expect(state.stars == before + 1)
        // Ganz fröhlich: weiteres Tippen bringt keine Sterne mehr.
        for _ in 0..<20 { state.pet(at: start) }
        let full = state.stars
        for _ in 0..<(LabubuState.petsPerStar * 3) { state.pet(at: start) }
        #expect(state.stars == full)
    }

    @Test func goodSleepEarnsStarsButNotWhenAlreadyRested() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        let before = state.stars
        state.sleep(at: start)
        state.wakeUp(at: start.addingTimeInterval(Needs.sleepRefillDuration))
        #expect(state.stars == before + LabubuState.starsPerGoodSleep)
        // Gleich wieder schlafen legen lohnt sich nicht.
        state.sleep(at: start.addingTimeInterval(40))
        state.wakeUp(at: start.addingTimeInterval(80))
        #expect(state.stars == before + LabubuState.starsPerGoodSleep)
    }

    @Test func wakingTooEarlyEarnsNothing() {
        var state = hatched()
        state.drainNeedsForTesting(at: start)
        let before = state.stars
        state.sleep(at: start)
        state.wakeUp(at: start.addingTimeInterval(3))
        #expect(state.stars == before)
    }

    @Test func freeItemsAreOwnedFromTheStart() {
        let state = hatched()
        #expect(state.owns(item("bow")))
        #expect(!state.owns(item("crown")))
    }

    @Test func buyingCostsStarsAndNeedsEnough() {
        var state = hatched() // 3 Sterne
        let crown = state.buy(item("crown")) // kostet 5
        #expect(!crown)
        #expect(state.stars == 3)
        let tophat = state.buy(item("tophat")) // kostet 3
        #expect(tophat)
        #expect(state.stars == 0)
        #expect(state.owns(item("tophat")))
        let again = state.buy(item("tophat"))
        #expect(again, "schon gekauft – kostet nichts mehr")
        #expect(state.stars == 0)
    }

    @Test func wearingReplacesItemInSameSlot() {
        var state = hatched()
        state.wear(item("crown"))
        #expect(state.wornItem(in: .head) == nil, "nicht gekauft – kann nicht angezogen werden")
        state.wear(item("bow"))
        #expect(state.wornItem(in: .head) == item("bow"))
        _ = state.buy(item("flower"))
        state.wear(item("flower"))
        #expect(state.wornItem(in: .head) == item("flower"))
        state.wear(item("glasses"))
        #expect(state.wornItem(in: .eyes) == item("glasses"))
        state.takeOff(.head)
        #expect(state.wornItem(in: .head) == nil)
        #expect(state.isWearing(item("glasses")))
    }

    @Test @MainActor func wardrobeTapBuysWearsAndTakesOff() {
        let store = GameStore(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).appendingPathComponent("s.json"))
        var seeded = hatched()
        seeded.wear(item("bow"))
        store.save(seeded)
        let vm = LabubuViewModel(store: store, tickInterval: nil)
        let results = [
            vm.useWardrobeItem(item("crown")),
            vm.useWardrobeItem(item("cap")),
        ]
        #expect(results == [.tooExpensive, .bought])
        #expect(vm.state.wornItem(in: .head) == item("cap"))
        let swap = [vm.useWardrobeItem(item("bow")), vm.useWardrobeItem(item("bow"))]
        #expect(swap == [.putOn, .tookOff])
        #expect(vm.state.wornItem(in: .head) == nil)
    }

    @Test func weekTwoSaveStillLoads() throws {
        let json = #"{"eggTaps":18,"hatchedAt":800000000,"needsUpdatedAt":800000000,"needs":{"hunger":0.5,"fun":0.5,"energy":0.5}}"#
        let state = try JSONDecoder().decode(LabubuState.self, from: Data(json.utf8))
        #expect(state.stars == 0)
        #expect(state.owns(OutfitItem.find("bow")!))
        #expect(state.worn.isEmpty)
    }

    @Test func catalogIsConsistent() {
        let ids = OutfitItem.catalog.map(\.id)
        #expect(Set(ids).count == ids.count, "IDs eindeutig")
        #expect(OutfitItem.catalog.allSatisfy { $0.price <= 5 }, "Preis als höchstens 5 Sterne darstellbar")
    }
}
