//
//  HomeScreenComponents.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import SwiftUI

/// Displays the home header with a greeting and settings entry point.
struct HomeHeaderView: View {
    let greeting: String
    let currencySettingsViewModel: CurrencySettingsViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting.isEmpty ? "Welcome back" : greeting)
                    .font(.title3.weight(.semibold))

                Text("Your money at a glance.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            NavigationLink {
                SettingsView(currencySettingsViewModel: currencySettingsViewModel)
            } label: {
                Image(systemName: "gearshape")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(.background, in: Circle())
            }
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("home.openSettingsButton")
        }
    }
}

/// Displays the balance hero card for the account.
struct HomeBalanceCardView: View {
    let title: String
    let amount: String
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            Text(isLoading ? "$12,345.67" : amount)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
                .accessibilityIdentifier("home.balanceAmountText")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(.background, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.05))
        )
        .shadow(color: .black.opacity(0.04), radius: 18, y: 10)
        .redacted(reason: isLoading ? .placeholder : [])
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(amount)")
        .accessibilityIdentifier("home.balanceCard")
    }
}

/// Displays the recent activity section and its transactions.
struct HomeRecentTransactionsSectionView: View {
    let sectionTitle: String
    let transactions: [HomeTransactionRowState]
    let emptyMessage: String?
    let isLoading: Bool

    private let placeholderRows = HomeRecentTransactionsSectionView.placeholderTransactions

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(sectionTitle)
                .font(.headline)

            if isLoading {
                VStack(spacing: 12) {
                    ForEach(placeholderRows) { transaction in
                        HomeTransactionRowView(transaction: transaction)
                    }
                }
                .redacted(reason: .placeholder)
            } else if let emptyMessage {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(transactions) { transaction in
                        HomeTransactionRowView(transaction: transaction)
                    }
                }
            }
        }
        .accessibilityIdentifier("home.transactionsSection")
    }

    private static let placeholderTransactions: [HomeTransactionRowState] = [
        HomeTransactionRowState(
            id: UUID(),
            title: "Merchant name",
            subtitle: "Today",
            amountText: "-$24.00",
            iconSystemName: "bag.fill",
            accessibilityLabel: "",
            isCredit: false
        ),
        HomeTransactionRowState(
            id: UUID(),
            title: "Incoming transfer",
            subtitle: "Yesterday",
            amountText: "+$250.00",
            iconSystemName: "arrow.down.left.circle.fill",
            accessibilityLabel: "",
            isCredit: true
        ),
        HomeTransactionRowState(
            id: UUID(),
            title: "Coffee",
            subtitle: "2 days ago",
            amountText: "-$4.50",
            iconSystemName: "cup.and.saucer.fill",
            accessibilityLabel: "",
            isCredit: false
        )
    ]
}

/// Displays a single recent-transaction row.
struct HomeTransactionRowView: View {
    let transaction: HomeTransactionRowState

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: transaction.iconSystemName)
                .font(.headline)
                .foregroundStyle(transaction.isCredit ? .green : .primary)
                .frame(width: 42, height: 42)
                .background(Color.primary.opacity(0.06), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(transaction.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Text(transaction.amountText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(transaction.isCredit ? .green : .primary)
                .monospacedDigit()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(transaction.accessibilityLabel)
    }
}

/// Displays the inline load-failure state for the home screen.
struct HomeErrorCardView: View {
    let errorState: HomeScreenErrorState
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(errorState.title)
                .font(.headline)

            Text(errorState.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(errorState.actionTitle, action: retry)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
