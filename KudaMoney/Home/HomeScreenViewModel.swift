//
//  HomeScreenViewModel.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation
import Observation

/// Coordinates loading, refresh, and display state for the home screen.
@MainActor
@Observable
final class HomeScreenViewModel {
    @ObservationIgnored
    private let dataProvider: any HomeScreenDataProviding

    @ObservationIgnored
    private let stateFactory: HomeScreenStateFactory

    @ObservationIgnored
    private var loadTask: Task<Void, Never>?

    private var hasLoaded = false
    private var currentCurrencyCode = "USD"
    private var lastSnapshot: HomeAccountSnapshot?

    /// The current state consumed by the view layer.
    var state: HomeScreenState

    /// Debug-only switch that allows the error UI to be exercised.
    var simulateError = false

    /// Creates a home-screen view model with the app's default dependencies.
    convenience init() {
        self.init(
            dataProvider: SampleHomeScreenDataProvider(),
            stateFactory: Self.makeDefaultStateFactory(),
            state: HomeScreenState()
        )
    }

    /// Creates a home-screen view model with a custom data provider and the default state mapping.
    /// - Parameter dataProvider: The data provider used to fetch the account snapshot.
    convenience init(dataProvider: any HomeScreenDataProviding) {
        self.init(
            dataProvider: dataProvider,
            stateFactory: Self.makeDefaultStateFactory(),
            state: HomeScreenState()
        )
    }

    /// Creates a home-screen view model with custom loading and mapping dependencies.
    /// - Parameters:
    ///   - dataProvider: The data provider used to fetch the account snapshot.
    ///   - stateFactory: The mapper that converts domain data into screen state.
    convenience init(
        dataProvider: any HomeScreenDataProviding,
        stateFactory: HomeScreenStateFactory
    ) {
        self.init(
            dataProvider: dataProvider,
            stateFactory: stateFactory,
            state: HomeScreenState()
        )
    }

    /// Creates a home-screen view model.
    /// - Parameters:
    ///   - dataProvider: The data provider used to fetch the account snapshot.
    ///   - stateFactory: The mapper that converts domain data into screen state.
    ///   - state: The initial screen state used before the first load completes.
    init(
        dataProvider: any HomeScreenDataProviding,
        stateFactory: HomeScreenStateFactory,
        state: HomeScreenState
    ) {
        self.dataProvider = dataProvider
        self.stateFactory = stateFactory
        self.state = state
    }

    /// Loads the home screen once on first appearance.
    /// - Parameter currencyCode: The active ISO 4217 currency code.
    func loadIfNeeded(currencyCode: String) async {
        currentCurrencyCode = currencyCode

        guard !hasLoaded else {
            return
        }

        await load()
    }

    /// Refreshes the home screen data.
    /// - Parameter currencyCode: The active ISO 4217 currency code.
    func refresh(currencyCode: String) async {
        currentCurrencyCode = currencyCode
        await load()
    }

    /// Retries the current home-screen load after an error.
    /// - Parameter currencyCode: The active ISO 4217 currency code.
    func retry(currencyCode: String) async {
        currentCurrencyCode = currencyCode
        await load()
    }

    /// Updates the rendered currency without refetching the sample data.
    /// - Parameter currencyCode: The new ISO 4217 currency code.
    func updateCurrencyCode(_ currencyCode: String) {
        currentCurrencyCode = currencyCode

        guard let lastSnapshot else {
            return
        }

        state = stateFactory.makeLoadedState(
            snapshot: lastSnapshot,
            currencyCode: currencyCode
        )
    }

    /// Cancels any in-flight load task.
    func cancelLoading() {
        loadTask?.cancel()
        loadTask = nil

        guard let lastSnapshot else {
            return
        }

        state = stateFactory.makeLoadedState(
            snapshot: lastSnapshot,
            currencyCode: currentCurrencyCode
        )
    }

    /// Creates a loaded sample view model for previews.
    /// - Parameter currencyCode: The currency code used for formatted preview values.
    /// - Returns: A preview-ready home view model.
    static func preview(currencyCode: String) -> HomeScreenViewModel {
        let stateFactory = makeDefaultStateFactory()
        let snapshot = SampleHomeScreenDataProvider.sampleSnapshot(referenceDate: Date())
        let viewModel = HomeScreenViewModel(
            dataProvider: SampleHomeScreenDataProvider(loadDelayNanoseconds: 0),
            stateFactory: stateFactory,
            state: stateFactory.makeLoadedState(snapshot: snapshot, currencyCode: currencyCode)
        )

        viewModel.lastSnapshot = snapshot
        viewModel.hasLoaded = true
        viewModel.currentCurrencyCode = currencyCode
        return viewModel
    }

    /// Builds the default state factory used by the app's home experience.
    /// - Returns: A state factory configured with the default formatters and greeting provider.
    private static func makeDefaultStateFactory() -> HomeScreenStateFactory {
        HomeScreenStateFactory(
            greetingProvider: TimeOfDayGreetingProvider(),
            rowBuilder: HomeTransactionRowBuilder(
                currencyFormatter: CurrencyAmountFormatter(),
                relativeDateFormatter: RelativeHomeDateFormatter()
            ),
            currencyFormatter: CurrencyAmountFormatter(),
            referenceDateProvider: Date.init
        )
    }

    private func load() async {
        cancelLoading()
        state.isLoading = true
        state.error = nil

        loadTask = Task { [dataProvider, simulateError] in
            do {
                let snapshot = try await dataProvider.fetchHomeSnapshot(simulateError: simulateError)

                guard !Task.isCancelled else {
                    return
                }

                lastSnapshot = snapshot
                hasLoaded = true
                state = stateFactory.makeLoadedState(
                    snapshot: snapshot,
                    currencyCode: currentCurrencyCode
                )
            } catch is CancellationError {
                guard let lastSnapshot else {
                    return
                }

                state = stateFactory.makeLoadedState(
                    snapshot: lastSnapshot,
                    currencyCode: currentCurrencyCode
                )
            } catch {
                state = stateFactory.makeErrorState()
            }
        }

        await loadTask?.value
    }
}
