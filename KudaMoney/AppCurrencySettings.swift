//
//  AppCurrencySettings.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation
import Observation

enum AppCurrencySettings {
    static let storageKey = "defaultCurrencyCode"

    /// ISO 4217 codes users can pick as the app default. Order is product-driven (NGN/USD first).
    static let supportedCurrencyCodes: [String] = [
        "NGN", "USD", "GBP", "EUR", "CAD", "AUD", "GHS", "KES", "ZAR", "INR", "JPY", "CNY", "SAR", "AED",
    ]
}

protocol CurrencyPreferenceStoring: AnyObject {
    var selectedCurrencyCode: String { get set }
}

final class UserDefaultsCurrencyPreferenceStore: CurrencyPreferenceStoring {
    private let defaults: UserDefaults
    private let storageKey: String

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = AppCurrencySettings.storageKey
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
			
			// sort an array
			// 0(1)
			// array[1]
			// array.subscript(0)
    }

    var selectedCurrencyCode: String {
        get { defaults.string(forKey: storageKey) ?? "" }
        set { defaults.set(newValue, forKey: storageKey) }
    }
}

protocol CurrencyLocaleProviding {
    var currentCurrencyCode: String? { get }
    func localizedCurrencyName(for code: String) -> String?
}

struct SystemCurrencyLocaleProvider: CurrencyLocaleProviding {
    private let locale: Locale

    init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    var currentCurrencyCode: String? {
        locale.currency?.identifier
    }

    func localizedCurrencyName(for code: String) -> String? {
        locale.localizedString(forCurrencyCode: code)
    }
}

struct CurrencyCodeResolver {
    private let fallbackCode: String

    init(fallbackCode: String = "USD") {
        self.fallbackCode = fallbackCode
    }

    func resolveCode(storedValue: String, localeCurrencyCode: String?) -> String {
        let trimmed = storedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return localeCurrencyCode ?? fallbackCode
        }
        return trimmed
    }
}

struct CurrencyOption: Identifiable, Equatable {
    let code: String
    let title: String

    var id: String { code }
}

@MainActor
@Observable
final class CurrencySettingsViewModel {
    @ObservationIgnored
    private let preferenceStore: any CurrencyPreferenceStoring

    @ObservationIgnored
    private let localeProvider: any CurrencyLocaleProviding

    @ObservationIgnored
    private let codeResolver: CurrencyCodeResolver

    var selectedCurrencyCode: String

    /// Creates a settings view model with the app's default dependencies.
    convenience init() {
        self.init(
            preferenceStore: UserDefaultsCurrencyPreferenceStore(),
            localeProvider: SystemCurrencyLocaleProvider(),
            codeResolver: CurrencyCodeResolver()
        )
    }

    /// Creates a settings view model with injectable dependencies for testing and previews.
    /// - Parameters:
    ///   - preferenceStore: The store that persists the selected currency code.
    ///   - localeProvider: The provider that supplies locale-backed currency metadata.
    ///   - codeResolver: The resolver that produces the effective currency code.
    init(
        preferenceStore: any CurrencyPreferenceStoring,
        localeProvider: any CurrencyLocaleProviding,
        codeResolver: CurrencyCodeResolver
    ) {
        self.preferenceStore = preferenceStore
        self.localeProvider = localeProvider
        self.codeResolver = codeResolver
        self.selectedCurrencyCode = preferenceStore.selectedCurrencyCode
    }

    var effectiveCurrencyCode: String {
        codeResolver.resolveCode(
            storedValue: selectedCurrencyCode,
            localeCurrencyCode: localeProvider.currentCurrencyCode
        )
    }

    var currencyOptions: [CurrencyOption] {
        [CurrencyOption(code: "", title: "System default")] +
        AppCurrencySettings.supportedCurrencyCodes.map { code in
            let name = localeProvider.localizedCurrencyName(for: code) ?? code
            return CurrencyOption(code: code, title: "\(name) (\(code))")
        }
    }

    func updateSelectedCurrencyCode(_ code: String) {
        selectedCurrencyCode = code
        preferenceStore.selectedCurrencyCode = code
    }
}
