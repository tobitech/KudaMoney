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

    private enum LaunchArgument {
        static let defaultCurrencyCode = "-defaultCurrencyCode"
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
    func testChangingCurrencyInSettingsUpdatesHomeBalance() throws {
        let app = makeApp(
            hasCompletedOnboarding: true,
            defaultCurrencyCode: "USD"
        )
        app.launch()

        let balanceAmount = app.staticTexts["home.balanceAmountText"]
        XCTAssertTrue(balanceAmount.waitForExistence(timeout: 2))
        XCTAssertTrue(balanceAmount.label.contains("$"))

        app.buttons["home.openSettingsButton"].tap()
        XCTAssertTrue(app.otherElements["settings.root"].waitForExistence(timeout: 2))

        app.otherElements["settings.currencyPicker"].tap()

        let gbpOption = app.staticTexts["settings.currencyOption.GBP"]
        XCTAssertTrue(gbpOption.waitForExistence(timeout: 2))
        gbpOption.tap()

        navigateBackIfPossible(in: app)
        navigateBackIfPossible(in: app)

        XCTAssertTrue(app.otherElements["home.root"].waitForExistence(timeout: 2))
        XCTAssertTrue(balanceAmount.label.contains("£"))
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
    /// Creates the app with deterministic launch overrides for UI testing.
    /// - Parameters:
    ///   - hasCompletedOnboarding: Indicates whether onboarding should be skipped.
    ///   - defaultCurrencyCode: The optional initial currency code passed through launch arguments.
    /// - Returns: A configured application instance.
    func makeApp(
        hasCompletedOnboarding: Bool,
        defaultCurrencyCode: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment[LaunchEnvironment.hasCompletedOnboarding] = hasCompletedOnboarding ? "1" : "0"
        if let defaultCurrencyCode {
            app.launchArguments += [
                LaunchArgument.defaultCurrencyCode,
                defaultCurrencyCode,
            ]
        }
        return app
    }

    /// Navigates back a single level when a navigation-bar back button is available.
    /// - Parameter app: The running application under test.
    func navigateBackIfPossible(in app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        }
    }
}
