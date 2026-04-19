//
//  SettingsView.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

@Observable
class SettingsViewModel {
	
}

struct SettingsView: View {
	@AppStorage(AppCurrencySettings.storageKey)
	private var currencyCode = ""

	var body: some View {
		Form {
			Section {
				Picker("Default currency", selection: $currencyCode) {
					Text("System default")
						.tag("")

					ForEach(AppCurrencySettings.supportedCurrencyCodes, id: \.self) { code in
						Text(Self.rowTitle(for: code))
							.tag(code)
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

	private static func rowTitle(for code: String) -> String {
		let locale = Locale.autoupdatingCurrent
		let name = locale.localizedString(forCurrencyCode: code) ?? code
		return "\(name) (\(code))"
	}
}

#Preview {
	NavigationStack {
		SettingsView()
	}
}
