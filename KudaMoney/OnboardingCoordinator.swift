//
//  OnboardingCoordinator.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation
import Observation

enum OnboardingKeys {
    static let completion = "hasCompletedOnboarding"
    static let uiTestOverride = "UITests.hasCompletedOnboarding"
}

enum OnboardingLaunchOverride {
    case showOnboarding
    case skipOnboarding
}

protocol LaunchOverrideProviding {
    var onboardingOverride: OnboardingLaunchOverride? { get }
}

struct ProcessInfoLaunchOverrideProvider: LaunchOverrideProviding {
    let environment: [String: String]

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.environment = environment
    }

    var onboardingOverride: OnboardingLaunchOverride? {
        switch environment[OnboardingKeys.uiTestOverride] {
        case "0":
            return .showOnboarding
        case "1":
            return .skipOnboarding
        default:
            return nil
        }
    }
}

protocol OnboardingStateStoring: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
}

final class UserDefaultsOnboardingStateStore: OnboardingStateStoring {
    private let defaults: UserDefaults
    private let storageKey: String

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = OnboardingKeys.completion
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: storageKey) }
        set { defaults.set(newValue, forKey: storageKey) }
    }
}

struct OnboardingVisibilityPolicy {
    private let launchOverrideProvider: any LaunchOverrideProviding

    init(launchOverrideProvider: any LaunchOverrideProviding) {
        self.launchOverrideProvider = launchOverrideProvider
    }

    func shouldShowOnboarding(
        hasCompletedOnboarding: Bool,
        hasDismissedOnboardingInSession: Bool
    ) -> Bool {
        guard !hasDismissedOnboardingInSession else {
            return false
        }

        switch launchOverrideProvider.onboardingOverride {
        case .showOnboarding:
            return true
        case .skipOnboarding:
            return false
        case nil:
            return !hasCompletedOnboarding
        }
    }
}

@MainActor
@Observable
final class OnboardingCoordinator {
    @ObservationIgnored
    private let stateStore: any OnboardingStateStoring

    @ObservationIgnored
    private let visibilityPolicy: OnboardingVisibilityPolicy

    private var hasCompletedOnboarding: Bool
    private var hasDismissedOnboardingInSession = false

    /// Creates an onboarding coordinator with the app's default persistence and launch policy.
    convenience init() {
        self.init(
            stateStore: UserDefaultsOnboardingStateStore(),
            visibilityPolicy: OnboardingVisibilityPolicy(
                launchOverrideProvider: ProcessInfoLaunchOverrideProvider()
            )
        )
    }

    /// Creates an onboarding coordinator with injectable dependencies for testing and previews.
    /// - Parameters:
    ///   - stateStore: The store that persists onboarding completion.
    ///   - visibilityPolicy: The policy that decides whether onboarding should appear.
    init(
        stateStore: any OnboardingStateStoring,
        visibilityPolicy: OnboardingVisibilityPolicy
    ) {
        self.stateStore = stateStore
        self.visibilityPolicy = visibilityPolicy
        self.hasCompletedOnboarding = stateStore.hasCompletedOnboarding
    }

    var shouldShowOnboarding: Bool {
        visibilityPolicy.shouldShowOnboarding(
            hasCompletedOnboarding: hasCompletedOnboarding,
            hasDismissedOnboardingInSession: hasDismissedOnboardingInSession
        )
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        hasDismissedOnboardingInSession = true
        stateStore.hasCompletedOnboarding = true
    }
}
