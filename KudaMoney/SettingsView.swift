//
//  SettingsView.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

struct SettingsView: View {
    let currencySettingsViewModel: CurrencySettingsViewModel

    private var selectedCurrencyCode: Binding<String> {
        Binding(
            get: { currencySettingsViewModel.selectedCurrencyCode },
            set: { currencySettingsViewModel.updateSelectedCurrencyCode($0) }
        )
    }

    var body: some View {
        Form {
            Section {
                Picker("Default currency", selection: selectedCurrencyCode) {
                    ForEach(currencySettingsViewModel.currencyOptions) { option in
                        Text(option.title)
                            .tag(option.code)
                            .accessibilityIdentifier(
                                "settings.currencyOption.\(option.code.isEmpty ? "system" : option.code)"
                            )
                    }
                }
                .accessibilityIdentifier("settings.currencyPicker")
            } footer: {
                Text("Amounts in the app use this currency unless a feature specifies otherwise.")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.root")
    }
}

/// Renders a deterministic settings preview with GBP selected.
private struct SettingsViewPreviewContainer: View {
    private let currencySettingsViewModel: CurrencySettingsViewModel

    init() {
        let defaults = UserDefaults(suiteName: "SettingsViewPreview")!
        defaults.set("GBP", forKey: AppCurrencySettings.storageKey)

        self.currencySettingsViewModel = CurrencySettingsViewModel(
            preferenceStore: UserDefaultsCurrencyPreferenceStore(defaults: defaults),
            localeProvider: SystemCurrencyLocaleProvider(locale: Locale(identifier: "en_GB")),
            codeResolver: CurrencyCodeResolver()
        )
    }

    var body: some View {
        NavigationStack {
            SettingsView(currencySettingsViewModel: currencySettingsViewModel)
        }
    }
}

#Preview {
    SettingsViewPreviewContainer()
}
