//
//  KudaMoneyApp.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

enum OnboardingLaunchState {
    static let completionKey = "hasCompletedOnboarding"
    static let uiTestOverrideKey = "UITests.hasCompletedOnboarding"

    static func shouldShowOnboarding(
        storedCompletion: Bool,
        environment: [String: String]
    ) -> Bool {
        if let override = environment[uiTestOverrideKey] {
            switch override {
            case "0":
                return true
            case "1":
                return false
            default:
                break
            }
        }

        return !storedCompletion
    }
}

@main
struct KudaMoneyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    @AppStorage(OnboardingLaunchState.completionKey)
    private var hasCompletedOnboarding = false

    @State private var hasDismissedOnboarding = false

    private let environment = ProcessInfo.processInfo.environment

    private var shouldShowOnboarding: Bool {
        !hasDismissedOnboarding &&
        OnboardingLaunchState.shouldShowOnboarding(
            storedCompletion: hasCompletedOnboarding,
            environment: environment
        )
    }

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView {
                    hasCompletedOnboarding = true
                    hasDismissedOnboarding = true
                }
            } else {
                ContentView()
            }
        }
    }
}
