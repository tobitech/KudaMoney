//
//  HomeScreenSupport.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation

/// Loads account summary data for the home screen.
protocol HomeScreenDataProviding {
    /// Fetches the latest account snapshot.
    /// - Parameter simulateError: Indicates whether the loader should throw for debug verification.
    /// - Returns: A sample account snapshot for the home screen.
    func fetchHomeSnapshot(simulateError: Bool) async throws -> HomeAccountSnapshot
}

/// Provides greeting text based on the current time of day.
protocol HomeGreetingProviding {
    /// Produces the greeting shown in the screen header.
    /// - Parameter date: The date used to compute the greeting.
    /// - Returns: A short greeting phrase such as "Good morning".
    func greeting(for date: Date) -> String
}

/// Formats monetary values for display on the home screen.
protocol CurrencyAmountFormatting {
    /// Formats a decimal amount into a localized currency string.
    /// - Parameters:
    ///   - amount: The amount to format.
    ///   - currencyCode: The ISO 4217 currency code to display.
    /// - Returns: A formatted currency value.
    func string(from amount: Decimal, currencyCode: String) -> String
}

/// Formats dates into compact relative labels for transaction rows.
protocol RelativeDateFormatting {
    /// Produces a relative date string for a transaction.
    /// - Parameters:
    ///   - date: The transaction date.
    ///   - referenceDate: The reference date used for relative formatting.
    /// - Returns: A compact relative label such as "Today" or "2 days ago".
    func string(from date: Date, relativeTo referenceDate: Date) -> String
}

/// Builds transaction row state from domain transactions.
struct HomeTransactionRowBuilder {
    /// The formatter used for amount text.
    let currencyFormatter: any CurrencyAmountFormatting

    /// The formatter used for relative date text.
    let relativeDateFormatter: any RelativeDateFormatting

    /// Creates the transaction rows shown on the home screen.
    /// - Parameters:
    ///   - transactions: The domain transactions to transform.
    ///   - currencyCode: The ISO 4217 code used for amount formatting.
    ///   - referenceDate: The current reference date used for relative timestamps.
    /// - Returns: Render-ready transaction row state.
    func buildRows(
        from transactions: [HomeTransaction],
        currencyCode: String,
        referenceDate: Date
    ) -> [HomeTransactionRowState] {
        transactions.map { transaction in
            let amountText = transaction.direction.amountPrefix +
            currencyFormatter.string(from: transaction.amount, currencyCode: currencyCode)
            let subtitle = relativeDateFormatter.string(from: transaction.date, relativeTo: referenceDate)

            return HomeTransactionRowState(
                id: transaction.id,
                title: transaction.title,
                subtitle: subtitle,
                amountText: amountText,
                iconSystemName: transaction.category.symbolName,
                accessibilityLabel: "\(transaction.title), \(subtitle), \(transaction.direction.accessibilityVerb) \(currencyFormatter.string(from: transaction.amount, currencyCode: currencyCode))",
                isCredit: transaction.direction == .credit
            )
        }
    }
}

/// Builds the presentable home-screen state from the domain snapshot.
struct HomeScreenStateFactory {
    /// The greeting provider used for the header.
    let greetingProvider: any HomeGreetingProviding

    /// The row builder used for recent transactions.
    let rowBuilder: HomeTransactionRowBuilder

    /// The currency formatter used for the balance amount.
    let currencyFormatter: any CurrencyAmountFormatting

    /// The reference date supplier used for time-based formatting.
    let referenceDateProvider: () -> Date

    /// Creates the loaded screen state from a domain snapshot.
    /// - Parameters:
    ///   - snapshot: The current account data.
    ///   - currencyCode: The ISO 4217 code used for formatting.
    /// - Returns: A loaded home-screen state.
    func makeLoadedState(
        snapshot: HomeAccountSnapshot,
        currencyCode: String
    ) -> HomeScreenState {
        let referenceDate = referenceDateProvider()
        let greeting = "\(greetingProvider.greeting(for: referenceDate)), \(snapshot.accountHolderName)"
        let transactions = rowBuilder.buildRows(
            from: snapshot.recentTransactions,
            currencyCode: currencyCode,
            referenceDate: referenceDate
        )

        return HomeScreenState(
            greeting: greeting,
            balanceTitle: "Available balance",
            balanceAmount: currencyFormatter.string(
                from: snapshot.availableBalance,
                currencyCode: currencyCode
            ),
            recentActivityTitle: "Recent activity",
            transactions: transactions,
            isLoading: false,
            emptyMessage: transactions.isEmpty ? "No recent activity." : nil,
            error: nil
        )
    }

    /// Creates the inline error state for the screen.
    /// - Returns: A display-ready error state.
    func makeErrorState() -> HomeScreenState {
        HomeScreenState(
            greeting: "",
            balanceTitle: "Available balance",
            balanceAmount: "",
            recentActivityTitle: "Recent activity",
            transactions: [],
            isLoading: false,
            emptyMessage: nil,
            error: HomeScreenErrorState(
                title: "Unable to load account",
                message: "We couldn't retrieve your latest details. Please try again.",
                actionTitle: "Try again"
            )
        )
    }
}

/// Supplies deterministic sample data for the first version of Home.
struct SampleHomeScreenDataProvider: HomeScreenDataProviding {
    /// The simulated network delay used for loading and refresh.
    let loadDelayNanoseconds: UInt64

    /// Creates a sample data provider.
    /// - Parameter loadDelayNanoseconds: The artificial delay before data returns.
    init(loadDelayNanoseconds: UInt64 = 1_000_000_000) {
        self.loadDelayNanoseconds = loadDelayNanoseconds
    }

    /// Fetches the sample home-screen snapshot.
    /// - Parameter simulateError: Indicates whether the fetch should fail.
    /// - Returns: A sample snapshot used by the screen.
    func fetchHomeSnapshot(simulateError: Bool) async throws -> HomeAccountSnapshot {
        try await Task.sleep(nanoseconds: loadDelayNanoseconds)

        if simulateError {
            throw HomeScreenSampleError.simulatedFailure
        }

        return Self.sampleSnapshot(referenceDate: Date())
    }

    /// Creates the canonical sample snapshot for previews and tests.
    /// - Parameter referenceDate: The date used to offset sample transactions.
    /// - Returns: A deterministic sample account snapshot.
    static func sampleSnapshot(referenceDate: Date) -> HomeAccountSnapshot {
        let calendar = Calendar.autoupdatingCurrent

        return HomeAccountSnapshot(
            accountHolderName: "Ada",
            availableBalance: Decimal(string: "4250.12") ?? 4250.12,
            recentTransactions: [
                HomeTransaction(
                    id: UUID(uuidString: "F001D0E6-0000-4000-8000-000000000001") ?? UUID(),
                    title: "Salary",
                    date: calendar.date(byAdding: .hour, value: -3, to: referenceDate) ?? referenceDate,
                    amount: Decimal(string: "2500.00") ?? 2500,
                    direction: .credit,
                    category: .salary
                ),
                HomeTransaction(
                    id: UUID(uuidString: "F001D0E6-0000-4000-8000-000000000002") ?? UUID(),
                    title: "Starbucks",
                    date: calendar.date(byAdding: .hour, value: -8, to: referenceDate) ?? referenceDate,
                    amount: Decimal(string: "4.50") ?? 4.5,
                    direction: .debit,
                    category: .coffee
                ),
                HomeTransaction(
                    id: UUID(uuidString: "F001D0E6-0000-4000-8000-000000000003") ?? UUID(),
                    title: "Uber",
                    date: calendar.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate,
                    amount: Decimal(string: "18.90") ?? 18.9,
                    direction: .debit,
                    category: .transport
                ),
                HomeTransaction(
                    id: UUID(uuidString: "F001D0E6-0000-4000-8000-000000000004") ?? UUID(),
                    title: "Apple Store",
                    date: calendar.date(byAdding: .day, value: -2, to: referenceDate) ?? referenceDate,
                    amount: Decimal(string: "79.99") ?? 79.99,
                    direction: .debit,
                    category: .shopping
                )
            ]
        )
    }
}

/// Implements time-of-day greetings for the home-screen header.
struct TimeOfDayGreetingProvider: HomeGreetingProviding {
    /// Produces a time-aware greeting.
    /// - Parameter date: The date used to choose the greeting.
    /// - Returns: "Good morning", "Good afternoon", or "Good evening".
    func greeting(for date: Date) -> String {
        let hour = Calendar.autoupdatingCurrent.component(.hour, from: date)

        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
}

/// Formats amounts into locale-aware currency strings.
struct CurrencyAmountFormatter: CurrencyAmountFormatting {
    /// Formats the given amount using the provided currency code.
    /// - Parameters:
    ///   - amount: The amount to format.
    ///   - currencyCode: The ISO 4217 currency code to display.
    /// - Returns: A user-facing currency string.
    func string(from amount: Decimal, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

/// Formats transaction dates into compact relative labels.
struct RelativeHomeDateFormatter: RelativeDateFormatting {
    /// Formats the transaction date relative to the current date.
    /// - Parameters:
    ///   - date: The transaction date to format.
    ///   - referenceDate: The reference date used to compare relative time.
    /// - Returns: A compact relative label.
    func string(from date: Date, relativeTo referenceDate: Date) -> String {
        let calendar = Calendar.autoupdatingCurrent

        if calendar.isDateInToday(date) {
            return "Today"
        }

        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }
}

/// Defines the sample-data error used to verify the home-screen failure state.
enum HomeScreenSampleError: Error {
    case simulatedFailure
}
