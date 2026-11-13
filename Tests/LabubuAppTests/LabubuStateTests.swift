import Foundation
import Testing
@testable import LabubuApp

struct LabubuStateTests {
    @Test func everyTapCountsUntilHatching() {
        var state = LabubuState()
        for _ in 0..<(LabubuState.tapsToHatch - 1) { state.tapEgg() }
        #expect(state.stage == .egg)
        state.tapEgg()
        #expect(state.stage == .hatching)
        #expect(state.hatchProgress == 1)
        #expect(state.filledHearts == LabubuState.progressHearts)
    }

    @Test func extraTapsAfterHatchingAreIgnored() {
        var state = LabubuState()
        for _ in 0..<(LabubuState.tapsToHatch + 5) { state.tapEgg() }
        #expect(state.eggTaps == LabubuState.tapsToHatch)
    }

    @Test func cracksGrowWithProgress() {
        var state = LabubuState()
        var levels: [Int] = [state.crackLevel]
        for _ in 0..<LabubuState.tapsToHatch {
            state.tapEgg()
            levels.append(state.crackLevel)
        }
        #expect(levels.first == 0)
        #expect(levels.last == LabubuState.crackLevels)
        #expect(levels == levels.sorted(), "Risse dürfen nie verschwinden")
        #expect(Set(levels) == Set(0...LabubuState.crackLevels), "jede Riss-Stufe wird sichtbar")
    }

    @Test func finishHatchingOnlyAfterEnoughTaps() {
        var state = LabubuState()
        state.finishHatching()
        #expect(state.stage == .egg)
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching()
        #expect(state.stage == .hatched)
    }
}

struct GameStoreTests {
    private func temporaryStore() -> GameStore {
        GameStore(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("spielstand.json"))
    }

    @Test func missingFileLoadsNothing() {
        #expect(temporaryStore().load() == nil)
    }

    @Test func savedStateLoadsBack() {
        let store = temporaryStore()
        var state = LabubuState()
        for _ in 0..<LabubuState.tapsToHatch { state.tapEgg() }
        state.finishHatching(at: Date(timeIntervalSince1970: 1_800_000_000))
        store.save(state)
        #expect(store.load() == state)
    }

    @Test @MainActor func viewModelRestoresProgressAfterRestart() {
        let store = temporaryStore()
        let first = LabubuViewModel(store: store, tickInterval: nil)
        first.tapEgg()
        first.tapEgg()
        let second = LabubuViewModel(store: store, tickInterval: nil)
        #expect(second.state.eggTaps == 2)
        second.resetGame()
        #expect(LabubuViewModel(store: store, tickInterval: nil).state.eggTaps == 0)
    }
}
