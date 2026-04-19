//
//  HomeScreenViewModelTests.swift
//  KudaMoneyTests
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation
import Testing
@testable import KudaMoney

struct HomeScreenViewModelTests {
    private struct StubHomeScreenDataProvider: HomeScreenDataProviding {
        let result: Result<HomeAccountSnapshot, Error>

        func fetchHomeSnapshot(simulateError: Bool) async throws -> HomeAccountSnapshot {
            if simulateError {
                throw HomeScreenSampleError.simulatedFailure
            }

            return try result.get()
        }
    }

    @Test
    @MainActor
    func loadPopulatesBalanceGreetingAndTransactions() async {
        let snapshot = SampleHomeScreenDataProvider.sampleSnapshot(
            referenceDate: Date(timeIntervalSince1970: 1_710_000_000)
        )
        let viewModel = HomeScreenViewModel(
            dataProvider: StubHomeScreenDataProvider(result: .success(snapshot)),
            stateFactory: HomeScreenStateFactory(
                greetingProvider: TimeOfDayGreetingProvider(),
                rowBuilder: HomeTransactionRowBuilder(
                    currencyFormatter: CurrencyAmountFormatter(),
                    relativeDateFormatter: RelativeHomeDateFormatter()
                ),
                currencyFormatter: CurrencyAmountFormatter(),
                referenceDateProvider: { Date(timeIntervalSince1970: 1_710_000_000) }
            )
        )

        await viewModel.loadIfNeeded(currencyCode: "USD")

        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.greeting.contains("Ada"))
        #expect(viewModel.state.balanceTitle == "Available balance")
        #expect(viewModel.state.transactions.count == 4)
        #expect(viewModel.state.error == nil)
    }

    @Test
    @MainActor
    func updateCurrencyCodeReformatsLoadedAmounts() async {
        let snapshot = SampleHomeScreenDataProvider.sampleSnapshot(
            referenceDate: Date(timeIntervalSince1970: 1_710_000_000)
        )
        let viewModel = HomeScreenViewModel(
            dataProvider: StubHomeScreenDataProvider(result: .success(snapshot)),
            stateFactory: HomeScreenStateFactory(
                greetingProvider: TimeOfDayGreetingProvider(),
                rowBuilder: HomeTransactionRowBuilder(
                    currencyFormatter: CurrencyAmountFormatter(),
                    relativeDateFormatter: RelativeHomeDateFormatter()
                ),
                currencyFormatter: CurrencyAmountFormatter(),
                referenceDateProvider: { Date(timeIntervalSince1970: 1_710_000_000) }
            )
        )

        await viewModel.loadIfNeeded(currencyCode: "USD")
        let previousBalance = viewModel.state.balanceAmount

        viewModel.updateCurrencyCode("GBP")

        #expect(previousBalance != viewModel.state.balanceAmount)
        #expect(viewModel.state.balanceAmount.contains("£"))
        #expect(viewModel.state.transactions.first?.amountText.contains("£") == true)
    }

    @Test
    @MainActor
    func simulateErrorProducesInlineErrorState() async {
        let snapshot = SampleHomeScreenDataProvider.sampleSnapshot(
            referenceDate: Date(timeIntervalSince1970: 1_710_000_000)
        )
        let viewModel = HomeScreenViewModel(
            dataProvider: StubHomeScreenDataProvider(result: .success(snapshot))
        )
        viewModel.simulateError = true

        await viewModel.loadIfNeeded(currencyCode: "USD")

        #expect(viewModel.state.error?.title == "Unable to load account")
        #expect(viewModel.state.transactions.isEmpty)
        #expect(!viewModel.state.isLoading)
    }

    @Test
    func stateFactoryCreatesEmptyMessageWhenTransactionsAreMissing() {
        let stateFactory = HomeScreenStateFactory(
            greetingProvider: TimeOfDayGreetingProvider(),
            rowBuilder: HomeTransactionRowBuilder(
                currencyFormatter: CurrencyAmountFormatter(),
                relativeDateFormatter: RelativeHomeDateFormatter()
            ),
            currencyFormatter: CurrencyAmountFormatter(),
            referenceDateProvider: { Date(timeIntervalSince1970: 1_710_000_000) }
        )
        let snapshot = HomeAccountSnapshot(
            accountHolderName: "Ada",
            availableBalance: Decimal(string: "120.00") ?? 120,
            recentTransactions: []
        )

        let state = stateFactory.makeLoadedState(snapshot: snapshot, currencyCode: "USD")

        #expect(state.emptyMessage == "No recent activity.")
        #expect(state.transactions.isEmpty)
    }
}
