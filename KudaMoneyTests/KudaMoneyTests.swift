//
//  KudaMoneyTests.swift
//  KudaMoneyTests
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Testing
@testable import KudaMoney

struct KudaMoneyTests {
    private final class InMemoryOnboardingStateStore: OnboardingStateStoring {
        var hasCompletedOnboarding: Bool

        init(hasCompletedOnboarding: Bool) {
            self.hasCompletedOnboarding = hasCompletedOnboarding
        }
    }

    private struct StubLaunchOverrideProvider: LaunchOverrideProviding {
        let onboardingOverride: OnboardingLaunchOverride?
    }

    private final class InMemoryCurrencyPreferenceStore: CurrencyPreferenceStoring {
        var selectedCurrencyCode: String

        init(selectedCurrencyCode: String) {
            self.selectedCurrencyCode = selectedCurrencyCode
        }
    }

    private struct StubCurrencyLocaleProvider: CurrencyLocaleProviding {
        let currentCurrencyCode: String?
        let localizedNames: [String: String]

        func localizedCurrencyName(for code: String) -> String? {
            localizedNames[code]
        }
    }

    @Test
    func showsOnboardingWhenCompletionIsMissing() {
        let policy = OnboardingVisibilityPolicy(
            launchOverrideProvider: StubLaunchOverrideProvider(onboardingOverride: nil)
        )

        #expect(
            policy.shouldShowOnboarding(
                hasCompletedOnboarding: false,
                hasDismissedOnboardingInSession: false
            )
        )
    }

    @Test
    func skipsOnboardingWhenCompletionIsStored() {
        let policy = OnboardingVisibilityPolicy(
            launchOverrideProvider: StubLaunchOverrideProvider(onboardingOverride: nil)
        )

        #expect(
            !policy.shouldShowOnboarding(
                hasCompletedOnboarding: true,
                hasDismissedOnboardingInSession: false
            )
        )
    }

    @Test
    func firstLaunchOverrideTakesPrecedence() {
        let policy = OnboardingVisibilityPolicy(
            launchOverrideProvider: StubLaunchOverrideProvider(onboardingOverride: .showOnboarding)
        )

        #expect(
            policy.shouldShowOnboarding(
                hasCompletedOnboarding: true,
                hasDismissedOnboardingInSession: false
            )
        )
    }

    @Test
    func returningUserOverrideTakesPrecedence() {
        let policy = OnboardingVisibilityPolicy(
            launchOverrideProvider: StubLaunchOverrideProvider(onboardingOverride: .skipOnboarding)
        )

        #expect(
            !policy.shouldShowOnboarding(
                hasCompletedOnboarding: false,
                hasDismissedOnboardingInSession: false
            )
        )
    }

    @Test
    func resolvesEmptyCurrencyToLocale() {
        let resolver = CurrencyCodeResolver()

        #expect(
            resolver.resolveCode(storedValue: "", localeCurrencyCode: "EUR") == "EUR"
        )
    }

    @Test
    func resolvesEmptyCurrencyToUSDFallback() {
        let resolver = CurrencyCodeResolver()

        #expect(
            resolver.resolveCode(storedValue: "", localeCurrencyCode: nil) == "USD"
        )
    }

    @Test
    func preservesExplicitCurrencyOverLocale() {
        let resolver = CurrencyCodeResolver()

        #expect(
            resolver.resolveCode(storedValue: "NGN", localeCurrencyCode: "USD") == "NGN"
        )
    }

    @Test
    func trimsWhitespaceFromStoredCurrency() {
        let resolver = CurrencyCodeResolver()

        #expect(
            resolver.resolveCode(storedValue: "  GBP  ", localeCurrencyCode: "USD") == "GBP"
        )
    }

    @Test
    @MainActor
    func completingOnboardingUpdatesStoredState() {
        let stateStore = InMemoryOnboardingStateStore(hasCompletedOnboarding: false)
        let coordinator = OnboardingCoordinator(
            stateStore: stateStore,
            visibilityPolicy: OnboardingVisibilityPolicy(
                launchOverrideProvider: StubLaunchOverrideProvider(onboardingOverride: .showOnboarding)
            )
        )

        coordinator.completeOnboarding()

        #expect(!coordinator.shouldShowOnboarding)
        #expect(stateStore.hasCompletedOnboarding)
    }

    @Test
    @MainActor
    func updatingSelectedCurrencyPersistsToStore() {
        let preferenceStore = InMemoryCurrencyPreferenceStore(selectedCurrencyCode: "")
        let viewModel = CurrencySettingsViewModel(
            preferenceStore: preferenceStore,
            localeProvider: StubCurrencyLocaleProvider(
                currentCurrencyCode: "EUR",
                localizedNames: ["NGN": "Nigerian Naira"]
            ),
            codeResolver: CurrencyCodeResolver()
        )

        viewModel.updateSelectedCurrencyCode("NGN")

        #expect(viewModel.selectedCurrencyCode == "NGN")
        #expect(viewModel.effectiveCurrencyCode == "NGN")
        #expect(preferenceStore.selectedCurrencyCode == "NGN")
    }

    @Test
    @MainActor
    func currencyOptionsIncludeSystemDefaultAndLocalizedLabels() {
        let viewModel = CurrencySettingsViewModel(
            preferenceStore: InMemoryCurrencyPreferenceStore(selectedCurrencyCode: ""),
            localeProvider: StubCurrencyLocaleProvider(
                currentCurrencyCode: "EUR",
                localizedNames: ["NGN": "Nigerian Naira"]
            ),
            codeResolver: CurrencyCodeResolver()
        )

        #expect(viewModel.currencyOptions.first == CurrencyOption(code: "", title: "System default"))
        #expect(
            viewModel.currencyOptions.contains(
                CurrencyOption(code: "NGN", title: "Nigerian Naira (NGN)")
            )
        )
    }
}
