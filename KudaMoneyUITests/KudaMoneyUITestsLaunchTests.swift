//
//  KudaMoneyUITestsLaunchTests.swift
//  KudaMoneyUITests
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//
// Kimi
import XCTest

final class KudaMoneyUITestsLaunchTests: XCTestCase {
    private enum LaunchEnvironment {
        static let hasCompletedOnboarding = "UITests.hasCompletedOnboarding"
    }

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchEnvironment[LaunchEnvironment.hasCompletedOnboarding] = "1"
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
