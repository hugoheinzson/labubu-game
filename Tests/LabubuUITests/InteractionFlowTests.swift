import XCTest

/// Läuft ausschließlich auf einem Simulator-Testgerät. Kein Reset auf dem echten iPad.
final class InteractionFlowTests: XCTestCase {
    private let app = XCUIApplication()

    private func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    private func expectValue(_ value: String, on element: XCUIElement, timeout: TimeInterval = 8) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: timeout), .completed)
    }

    private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func chooseClassicEgg() {
        let choice = element("egg-choice-classic")
        XCTAssertTrue(choice.waitForExistence(timeout: 5))
        attach("Eierauswahl")
        choice.tap()
    }

    func testEggNestFeedingExerciseAndSleep() throws {
        #if !targetEnvironment(simulator)
        throw XCTSkip("Dieser Test setzt den Spielstand zurück und darf nur im Simulator laufen.")
        #endif
        continueAfterFailure = false
        app.launch()
        let sound = app.buttons.matching(NSPredicate(format: "label IN %@", ["Ton einschalten", "Ton ausschalten"])).firstMatch
        XCTAssertTrue(sound.waitForExistence(timeout: 8))
        sound.press(forDuration: 3.3)
        let reset = app.buttons["Spiel zurücksetzen (neues Ei)"]
        XCTAssertTrue(reset.waitForExistence(timeout: 3))
        reset.tap()
        chooseClassicEgg()

        let egg = element("egg")
        XCTAssertTrue(egg.waitForExistence(timeout: 5))
        expectValue("Im Nest", on: egg)
        attach("01-Ei-im-Nest")

        let center = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let outside = app.coordinate(withNormalizedOffset: CGVector(dx: 0.78, dy: 0.5))
        egg.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: outside)
        expectValue("Außerhalb des Nests", on: egg)
        egg.tap()
        expectValue("0 von 6", on: element("heartsProgress"))
        attach("02-Ei-außerhalb-keine-Pflege")

        egg.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: center)
        expectValue("Im Nest", on: egg)
        for _ in 0..<18 { egg.tap() }

        let labubu = element("labubu")
        XCTAssertTrue(labubu.waitForExistence(timeout: 15))
        let stars = element("starCounter")
        expectValue("3", on: stars)
        let food = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'food-'" )).firstMatch
        XCTAssertTrue(food.exists)
        food.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: labubu.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18)))
        expectValue("3", on: stars)
        food.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: labubu.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.56)))
        expectValue("4", on: stars)
        attach("03-Erfolgreich-gefüttert")

        let energy = element("need-🌙")
        let before = try XCTUnwrap(Int(energy.value as? String ?? ""))
        let play = element("playButton")
        let readyToPlay = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: play)
        XCTAssertEqual(XCTWaiter.wait(for: [readyToPlay], timeout: 8), .completed)
        play.tap()
        let lowerEnergy = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            (Int(energy.value as? String ?? "") ?? 100) < before
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [lowerEnergy], timeout: 8), .completed)
        element("sleepButton").tap()
        expectValue("sleeping", on: labubu)
        XCTAssertFalse(element("playButton").isEnabled)
        attach("04-Schlaf-nach-dem-Spielen")
        app.terminate()
        app.launch()
        expectValue("sleeping", on: element("labubu"))
        element("newEggButton").tap()
        chooseClassicEgg()
        expectValue("Im Nest", on: egg)
        expectValue("0 von 6", on: element("heartsProgress"))
        egg.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: outside)
        expectValue("Außerhalb des Nests", on: egg)
        element("newEggButton").tap()
        chooseClassicEgg()
        expectValue("Im Nest", on: egg)
        attach("05-Claras-Neustartknopf")
    }
}
