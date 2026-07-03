import Foundation
import SwiftUI

enum TransactionKind: String, Codable, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }

    var label: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        }
    }
}

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case salary
    case groceries
    case dining
    case transport
    case housing
    case utilities
    case entertainment
    case health
    case shopping
    case travel
    case other

    var id: String { rawValue }

    var label: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .salary: return "dollarsign.circle.fill"
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .entertainment: return "tv.fill"
        case .health: return "heart.fill"
        case .shopping: return "bag.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .salary: return .green
        case .groceries: return .orange
        case .dining: return .red
        case .transport: return .blue
        case .housing: return .brown
        case .utilities: return .yellow
        case .entertainment: return .purple
        case .health: return .pink
        case .shopping: return .teal
        case .travel: return .indigo
        case .other: return .gray
        }
    }

    /// Categories that make sense for a given kind of transaction.
    static func categories(for kind: TransactionKind) -> [TransactionCategory] {
        switch kind {
        case .income: return [.salary, .other]
        case .expense: return allCases.filter { $0 != .salary }
        }
    }
}

struct Transaction: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: TransactionCategory
    var kind: TransactionKind

    /// Positive for income, negative for expenses.
    var signedAmount: Double {
        kind == .income ? amount : -amount
    }
}

struct Budget: Identifiable, Codable, Hashable {
    var id = UUID()
    var category: TransactionCategory
    var monthlyLimit: Double
}
