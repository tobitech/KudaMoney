//
//  KudaMoneyUITests.swift
//  KudaMoneyUITests
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import XCTest

final class KudaMoneyUITests: XCTestCase {
    private enum LaunchEnvironment {
        static let hasCompletedOnboarding = "UITests.hasCompletedOnboarding"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFirstLaunchShowsOnboardingAndContinuesToHome() throws {
        let app = makeApp(hasCompletedOnboarding: false)
        app.launch()

        XCTAssertTrue(app.otherElements["onboarding.root"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["onboarding.title"].exists)

        app.buttons["onboarding.getStartedButton"].tap()

        XCTAssertTrue(app.otherElements["home.root"].waitForExistence(timeout: 1))
    }

    @MainActor
    func testReturningUserLaunchSkipsOnboarding() throws {
        let app = makeApp(hasCompletedOnboarding: true)
        app.launch()

        XCTAssertTrue(app.otherElements["home.root"].waitForExistence(timeout: 1))
        XCTAssertFalse(app.otherElements["onboarding.root"].exists)
    }

    @MainActor
    func testOpensSettingsFromHome() throws {
        let app = makeApp(hasCompletedOnboarding: true)
        app.launch()

        XCTAssertTrue(app.otherElements["home.root"].waitForExistence(timeout: 1))

        app.buttons["home.openSettingsButton"].tap()

        XCTAssertTrue(app.otherElements["settings.root"].waitForExistence(timeout: 1))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            makeApp(hasCompletedOnboarding: true).launch()
        }
    }
}

private extension KudaMoneyUITests {
    func makeApp(hasCompletedOnboarding: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment[LaunchEnvironment.hasCompletedOnboarding] = hasCompletedOnboarding ? "1" : "0"
        return app
    }
}
