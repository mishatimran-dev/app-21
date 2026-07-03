import Foundation
import Combine

@MainActor
final class FinanceStore: ObservableObject {
    @Published var transactions: [Transaction] = [] {
        didSet { save() }
    }
    @Published var budgets: [Budget] = [] {
        didSet { save() }
    }
    @Published var currencyCode: String = Locale.current.currency?.identifier ?? "USD" {
        didSet { save() }
    }

    private struct Snapshot: Codable {
        var transactions: [Transaction]
        var budgets: [Budget]
        var currencyCode: String
    }

    private static var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("finance-data.json")
    }

    private var isLoading = false

    init() {
        load()
        if transactions.isEmpty && budgets.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - Mutations

    func add(_ transaction: Transaction) {
        transactions.append(transaction)
    }

    func remove(_ items: [Transaction], at offsets: IndexSet) {
        let ids = Set(offsets.map { items[$0].id })
        transactions.removeAll { ids.contains($0.id) }
    }

    func setBudget(_ limit: Double, for category: TransactionCategory) {
        if let index = budgets.firstIndex(where: { $0.category == category }) {
            budgets[index].monthlyLimit = limit
        } else {
            budgets.append(Budget(category: category, monthlyLimit: limit))
        }
    }

    func removeBudgets(at offsets: IndexSet) {
        budgets.remove(atOffsets: offsets)
    }

    func eraseAllData() {
        isLoading = true
        transactions = []
        budgets = []
        isLoading = false
        save()
    }

    // MARK: - Derived values

    var balance: Double {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    func transactions(in month: Date) -> [Transaction] {
        let calendar = Calendar.current
        return transactions.filter {
            calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
    }

    func income(in month: Date) -> Double {
        transactions(in: month)
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amount }
    }

    func expenses(in month: Date) -> Double {
        transactions(in: month)
            .filter { $0.kind == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    func spending(on category: TransactionCategory, in month: Date) -> Double {
        transactions(in: month)
            .filter { $0.kind == .expense && $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    func spendingByCategory(in month: Date) -> [(category: TransactionCategory, total: Double)] {
        let expenses = transactions(in: month).filter { $0.kind == .expense }
        let grouped = Dictionary(grouping: expenses, by: \.category)
        return grouped
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    // MARK: - Persistence

    private func save() {
        guard !isLoading else { return }
        let snapshot = Snapshot(
            transactions: transactions,
            budgets: budgets,
            currencyCode: currencyCode
        )
        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: Self.fileURL, options: [.atomic])
        } catch {
            print("Failed to save finance data: \(error)")
        }
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }
        guard let data = try? Data(contentsOf: Self.fileURL),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return
        }
        transactions = snapshot.transactions
        budgets = snapshot.budgets
        currencyCode = snapshot.currencyCode
    }

    // MARK: - Sample data

    func loadSampleData() {
        isLoading = true
        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        }

        transactions = [
            Transaction(title: "Monthly Salary", amount: 4200, date: daysAgo(2), category: .salary, kind: .income),
            Transaction(title: "Rent", amount: 1450, date: daysAgo(2), category: .housing, kind: .expense),
            Transaction(title: "Weekly Groceries", amount: 96.40, date: daysAgo(1), category: .groceries, kind: .expense),
            Transaction(title: "Electric Bill", amount: 72.15, date: daysAgo(3), category: .utilities, kind: .expense),
            Transaction(title: "Dinner Out", amount: 54.30, date: daysAgo(4), category: .dining, kind: .expense),
            Transaction(title: "Gas", amount: 41.80, date: daysAgo(5), category: .transport, kind: .expense),
            Transaction(title: "Streaming Subscription", amount: 15.99, date: daysAgo(6), category: .entertainment, kind: .expense),
            Transaction(title: "Pharmacy", amount: 23.50, date: daysAgo(7), category: .health, kind: .expense),
            Transaction(title: "New Headphones", amount: 129.99, date: daysAgo(9), category: .shopping, kind: .expense),
            Transaction(title: "Freelance Project", amount: 650, date: daysAgo(10), category: .other, kind: .income),
            Transaction(title: "Groceries", amount: 88.20, date: daysAgo(12), category: .groceries, kind: .expense),
            Transaction(title: "Coffee", amount: 6.75, date: daysAgo(12), category: .dining, kind: .expense),
            Transaction(title: "Monthly Salary", amount: 4200, date: daysAgo(32), category: .salary, kind: .income),
            Transaction(title: "Rent", amount: 1450, date: daysAgo(32), category: .housing, kind: .expense),
            Transaction(title: "Weekend Trip", amount: 380, date: daysAgo(35), category: .travel, kind: .expense),
        ]

        budgets = [
            Budget(category: .groceries, monthlyLimit: 450),
            Budget(category: .dining, monthlyLimit: 200),
            Budget(category: .transport, monthlyLimit: 150),
            Budget(category: .entertainment, monthlyLimit: 100),
            Budget(category: .shopping, monthlyLimit: 250),
        ]
        isLoading = false
        save()
    }
}
