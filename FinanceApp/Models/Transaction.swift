import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    var title: String
    var amount: Decimal
    var date: Date
    var categoryRaw: String
    var isExpense: Bool
    var note: String

    init(
        title: String,
        amount: Decimal,
        date: Date = .now,
        category: Category = .other,
        isExpense: Bool = true,
        note: String = ""
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.categoryRaw = category.rawValue
        self.isExpense = isExpense
        self.note = note
    }

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    /// Positive for income, negative for expenses.
    var signedAmount: Decimal {
        isExpense ? -amount : amount
    }
}

enum Category: String, CaseIterable, Identifiable, Codable {
    case food
    case transport
    case housing
    case entertainment
    case health
    case shopping
    case salary
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .food: "Food & Drink"
        case .transport: "Transport"
        case .housing: "Housing"
        case .entertainment: "Entertainment"
        case .health: "Health"
        case .shopping: "Shopping"
        case .salary: "Salary"
        case .other: "Other"
        }
    }

    var symbol: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .housing: "house.fill"
        case .entertainment: "popcorn.fill"
        case .health: "heart.fill"
        case .shopping: "bag.fill"
        case .salary: "dollarsign.circle.fill"
        case .other: "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: .orange
        case .transport: .blue
        case .housing: .brown
        case .entertainment: .purple
        case .health: .red
        case .shopping: .pink
        case .salary: .green
        case .other: .gray
        }
    }
}
