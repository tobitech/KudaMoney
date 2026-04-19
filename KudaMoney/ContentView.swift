//
//  ContentView.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(AppCurrencySettings.storageKey)
    private var storedCurrencyCode = ""

    private var currencyCode: String {
        AppCurrencySettings.resolveCode(
            storedValue: storedCurrencyCode,
            localeCurrencyCode: Locale.current.currency?.identifier
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("Hello, People!")

                Text(1234.56, format: .currency(code: currencyCode))
                    .font(.title2.weight(.semibold))
                    .accessibilityIdentifier("home.sampleCurrencyAmount")
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier("home.openSettingsButton")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("home.root")
        }
    }
}

#Preview {
    ContentView()
}
