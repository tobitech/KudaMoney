//
//  KudaMoneyApp.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

/// Composes shared app-level state and launches the root application flow.
@main
struct KudaMoneyApp: App {
    @State private var onboardingCoordinator = OnboardingCoordinator()
    @State private var currencySettingsViewModel = CurrencySettingsViewModel()
    @State private var homeViewModel = HomeScreenViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(
                onboardingCoordinator: onboardingCoordinator,
                currencySettingsViewModel: currencySettingsViewModel,
                homeViewModel: homeViewModel
            )
        }
    }
}

/// Chooses between onboarding and the authenticated home experience.
private struct RootView: View {
    let onboardingCoordinator: OnboardingCoordinator
    let currencySettingsViewModel: CurrencySettingsViewModel
    let homeViewModel: HomeScreenViewModel

    var body: some View {
        Group {
            if onboardingCoordinator.shouldShowOnboarding {
                OnboardingView {
                    onboardingCoordinator.completeOnboarding()
                }
            } else {
                ContentView(
                    currencySettingsViewModel: currencySettingsViewModel,
                    homeViewModel: homeViewModel
                )
            }
        }
    }
}
