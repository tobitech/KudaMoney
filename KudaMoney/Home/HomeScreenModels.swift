//
//  HomeScreenModels.swift
//  KudaMoney
//
//  Created by Oluwatobi Omotayo on 19/04/2026.
//

import Foundation

/// Represents the sample account snapshot displayed on the home screen.
struct HomeAccountSnapshot: Equatable {
    /// The first name displayed in the greeting.
    let accountHolderName: String

    /// The available account balance shown in the hero card.
    let availableBalance: Decimal

    /// The transactions displayed in the recent activity section.
    let recentTransactions: [HomeTransaction]
}

/// Describes a single recent account activity item.
struct HomeTransaction: Identifiable, Equatable {
    /// A stable identifier for diffing transaction rows.
    let id: UUID

    /// The merchant or transfer title shown in the row.
    let title: String

    /// The transaction timestamp used for relative-date formatting.
    let date: Date

    /// The amount associated with the transaction.
    let amount: Decimal

    /// The transaction direction used for copy and sign formatting.
    let direction: HomeTransactionDirection

    /// The category used to map the row to an SF Symbol.
    let category: HomeTransactionCategory
}

/// Describes whether a transaction adds or removes money from the account.
enum HomeTransactionDirection: Equatable {
    case credit
    case debit

    /// The sign prefix shown before the formatted amount.
    var amountPrefix: String {
        switch self {
        case .credit:
            return "+"
        case .debit:
            return "-"
        }
    }

    /// The accessibility verb that describes the transaction direction.
    var accessibilityVerb: String {
        switch self {
        case .credit:
            return "Credit of"
        case .debit:
            return "Debit of"
        }
    }
}

/// Maps sample transaction categories to semantic iconography.
enum HomeTransactionCategory: Equatable {
    case salary
    case coffee
    case shopping
    case transfer
    case transport

    /// The SF Symbol used for the category in the transaction row.
    var symbolName: String {
        switch self {
        case .salary:
            return "arrow.down.left.circle.fill"
        case .coffee:
            return "cup.and.saucer.fill"
        case .shopping:
            return "bag.fill"
        case .transfer:
            return "arrow.left.arrow.right.circle.fill"
        case .transport:
            return "car.fill"
        }
    }
}

/// Represents the presentation state for the home screen.
struct HomeScreenState: Equatable {
    /// The localized greeting shown in the header.
    var greeting = ""

    /// The helper title above the balance amount.
    var balanceTitle = "Available balance"

    /// The formatted account balance string.
    var balanceAmount = ""

    /// The title above the transaction list.
    var recentActivityTitle = "Recent activity"

    /// The prepared transaction rows for rendering.
    var transactions: [HomeTransactionRowState] = []

    /// Indicates whether the screen is in a loading phase.
    var isLoading = true

    /// The optional empty-state copy for transactions.
    var emptyMessage: String?

    /// The optional inline error content for load failures.
    var error: HomeScreenErrorState?
}

/// Represents a single rendered transaction row.
struct HomeTransactionRowState: Identifiable, Equatable {
    /// The stable identifier used in list rendering.
    let id: UUID

    /// The merchant or transfer name.
    let title: String

    /// The relative date string shown under the title.
    let subtitle: String

    /// The formatted amount shown on the trailing edge.
    let amountText: String

    /// The SF Symbol displayed in the leading icon circle.
    let iconSystemName: String

    /// The full accessibility label for VoiceOver.
    let accessibilityLabel: String

    /// Indicates whether the transaction is incoming.
    let isCredit: Bool
}

/// Represents the inline error UI for the home screen.
struct HomeScreenErrorState: Equatable {
    /// The main error title.
    let title: String

    /// The descriptive helper copy beneath the title.
    let message: String

    /// The retry action label.
    let actionTitle: String
}
