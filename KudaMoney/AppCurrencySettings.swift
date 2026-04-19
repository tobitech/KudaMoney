//
//  AppCurrencySettings.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation

enum AppCurrencySettings {
    static let storageKey = "defaultCurrencyCode"

    /// ISO 4217 codes users can pick as the app default. Order is product-driven (NGN/USD first).
    static let supportedCurrencyCodes: [String] = [
        "NGN", "USD", "GBP", "EUR", "CAD", "AUD", "GHS", "KES", "ZAR", "INR", "JPY", "CNY", "SAR", "AED",
    ]

    static func resolveCode(storedValue: String, localeCurrencyCode: String?) -> String {
        let trimmed = storedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return localeCurrencyCode ?? "USD"
        }
        return trimmed
    }
}
