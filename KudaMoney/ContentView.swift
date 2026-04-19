//
//  ContentView.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

/// Hosts the neo-bank home screen and binds it to shared app-level settings.
struct ContentView: View {
    let currencySettingsViewModel: CurrencySettingsViewModel
    let homeViewModel: HomeScreenViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HomeHeaderView(
                        greeting: homeViewModel.state.greeting,
                        currencySettingsViewModel: currencySettingsViewModel
                    )

                    if let errorState = homeViewModel.state.error, !homeViewModel.state.isLoading {
                        HomeErrorCardView(
                            errorState: errorState,
                            retry: {
                                Task {
                                    await homeViewModel.retry(
                                        currencyCode: currencySettingsViewModel.effectiveCurrencyCode
                                    )
                                }
                            }
                        )
                    } else {
                        HomeBalanceCardView(
                            title: homeViewModel.state.balanceTitle,
                            amount: homeViewModel.state.balanceAmount,
                            isLoading: homeViewModel.state.isLoading
                        )

                        HomeRecentTransactionsSectionView(
                            sectionTitle: homeViewModel.state.recentActivityTitle,
                            transactions: homeViewModel.state.transactions,
                            emptyMessage: homeViewModel.state.emptyMessage,
                            isLoading: homeViewModel.state.isLoading
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .refreshable {
                await homeViewModel.refresh(
                    currencyCode: currencySettingsViewModel.effectiveCurrencyCode
                )
            }
            .task {
                await homeViewModel.loadIfNeeded(
                    currencyCode: currencySettingsViewModel.effectiveCurrencyCode
                )
            }
            .onDisappear {
                homeViewModel.cancelLoading()
            }
            .onChange(of: currencySettingsViewModel.effectiveCurrencyCode) { _, newValue in
                homeViewModel.updateCurrencyCode(newValue)
            }
            .accessibilityIdentifier("home.root")
        }
    }
}

/// Renders a deterministic GBP-based home preview.
private struct ContentViewPreviewContainer: View {
    private let currencySettingsViewModel: CurrencySettingsViewModel
    private let homeViewModel: HomeScreenViewModel

    init() {
        let defaults = UserDefaults(suiteName: "ContentViewPreview")!
        defaults.set("GBP", forKey: AppCurrencySettings.storageKey)

        let currencySettingsViewModel = CurrencySettingsViewModel(
            preferenceStore: UserDefaultsCurrencyPreferenceStore(defaults: defaults),
            localeProvider: SystemCurrencyLocaleProvider(locale: Locale(identifier: "en_GB")),
            codeResolver: CurrencyCodeResolver()
        )

        self.currencySettingsViewModel = currencySettingsViewModel
        self.homeViewModel = HomeScreenViewModel.preview(
            currencyCode: currencySettingsViewModel.effectiveCurrencyCode
        )
    }

    var body: some View {
        ContentView(
            currencySettingsViewModel: currencySettingsViewModel,
            homeViewModel: homeViewModel
        )
    }
}

#Preview {
    ContentViewPreviewContainer()
}
