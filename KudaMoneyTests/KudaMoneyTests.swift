//
//  KudaMoneyTests.swift
//  KudaMoneyTests
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Testing
@testable import KudaMoney

struct KudaMoneyTests {

    @Test
    func showsOnboardingWhenCompletionIsMissing() {
        #expect(
            OnboardingLaunchState.shouldShowOnboarding(
                storedCompletion: false,
                environment: [:]
            )
        )
    }

    @Test
    func skipsOnboardingWhenCompletionIsStored() {
        #expect(
            !OnboardingLaunchState.shouldShowOnboarding(
                storedCompletion: true,
                environment: [:]
            )
        )
    }

    @Test
    func firstLaunchOverrideTakesPrecedence() {
        #expect(
            OnboardingLaunchState.shouldShowOnboarding(
                storedCompletion: true,
                environment: [OnboardingLaunchState.uiTestOverrideKey: "0"]
            )
        )
    }

    @Test
    func returningUserOverrideTakesPrecedence() {
        #expect(
            !OnboardingLaunchState.shouldShowOnboarding(
                storedCompletion: false,
                environment: [OnboardingLaunchState.uiTestOverrideKey: "1"]
            )
        )
    }

    @Test
    func resolvesEmptyCurrencyToLocale() {
        #expect(
            AppCurrencySettings.resolveCode(storedValue: "", localeCurrencyCode: "EUR") == "EUR"
        )
    }

    @Test
    func resolvesEmptyCurrencyToUSDFallback() {
        #expect(
            AppCurrencySettings.resolveCode(storedValue: "", localeCurrencyCode: nil) == "USD"
        )
    }

    @Test
    func preservesExplicitCurrencyOverLocale() {
        #expect(
            AppCurrencySettings.resolveCode(storedValue: "NGN", localeCurrencyCode: "USD") == "NGN"
        )
    }

    @Test
    func trimsWhitespaceFromStoredCurrency() {
        #expect(
            AppCurrencySettings.resolveCode(storedValue: "  GBP  ", localeCurrencyCode: "USD") == "GBP"
        )
    }
}
