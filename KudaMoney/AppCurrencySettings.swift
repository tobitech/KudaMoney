//
//  AppCurrencySettings.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation
import Observation

/// Stores constants and launch-time helpers related to currency selection.
enum AppCurrencySettings {
    static let storageKey = "defaultCurrencyCode"

    /// ISO 4217 codes users can pick as the app default. Order is product-driven (NGN/USD first).
    static let supportedCurrencyCodes: [String] = [
        "NGN", "USD", "GBP", "EUR", "CAD", "AUD", "GHS", "KES", "ZAR", "INR", "JPY", "CNY", "SAR", "AED",
    ]
}

/// Parses launch arguments that influence the initial app currency.
enum AppCurrencyLaunchArgument {
    /// The launch argument used to seed the default currency during UI tests.
    static let defaultCurrencyCodeFlag = "-defaultCurrencyCode"

    /// Extracts the currency override from a launch-argument list.
    /// - Parameter arguments: The raw process launch arguments.
    /// - Returns: The ISO 4217 code supplied after the override flag, if present.
    static func currencyCode(from arguments: [String]) -> String? {
        guard let flagIndex = arguments.firstIndex(of: defaultCurrencyCodeFlag) else {
            return nil
        }

        let valueIndex = arguments.index(after: flagIndex)
        guard arguments.indices.contains(valueIndex) else {
            return nil
        }

        let candidate = arguments[valueIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        return candidate.isEmpty ? nil : candidate
    }
}

/// Persists the selected currency code.
protocol CurrencyPreferenceStoring: AnyObject {
    var selectedCurrencyCode: String { get set }
}

/// Stores the selected currency in `UserDefaults`.
final class UserDefaultsCurrencyPreferenceStore: CurrencyPreferenceStoring {
    private let defaults: UserDefaults
    private let storageKey: String

    /// Creates a currency preference store.
    /// - Parameters:
    ///   - defaults: The defaults container used for persistence.
    ///   - storageKey: The key used to store the selected currency.
    ///   - arguments: The launch arguments that can override the initial currency.
    init(
        defaults: UserDefaults = .standard,
        storageKey: String = AppCurrencySettings.storageKey,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        self.defaults = defaults
        self.storageKey = storageKey

        if let launchCurrencyCode = AppCurrencyLaunchArgument.currencyCode(from: arguments) {
            defaults.set(launchCurrencyCode, forKey: storageKey)
        }
    }

    var selectedCurrencyCode: String {
        get { defaults.string(forKey: storageKey) ?? "" }
        set { defaults.set(newValue, forKey: storageKey) }
    }
}

/// Supplies locale-backed currency metadata.
protocol CurrencyLocaleProviding {
    var currentCurrencyCode: String? { get }
    func localizedCurrencyName(for code: String) -> String?
}

/// Adapts the current locale into currency metadata for the app.
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

/// Resolves the effective currency code used across the app.
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

/// Represents a selectable currency option in Settings.
struct CurrencyOption: Identifiable, Equatable {
    let code: String
    let title: String

    var id: String { code }
}

/// Coordinates currency selection and locale-aware currency metadata for Settings and Home.
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
