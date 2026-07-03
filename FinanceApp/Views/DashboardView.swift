import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var balance: Decimal {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    private var monthTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
    }

    private var monthIncome: Decimal {
        monthTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    private var monthExpenses: Decimal {
        monthTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    private var spendingByCategory: [(category: Category, total: Decimal)] {
        let expenses = monthTransactions.filter(\.isExpense)
        let grouped = Dictionary(grouping: expenses, by: \.category)
        return grouped
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard

                    HStack(spacing: 16) {
                        summaryCard(
                            title: "Income",
                            amount: monthIncome,
                            symbol: "arrow.down.circle.fill",
                            tint: .green
                        )
                        summaryCard(
                            title: "Expenses",
                            amount: monthExpenses,
                            symbol: "arrow.up.circle.fill",
                            tint: .red
                        )
                    }

                    if !spendingByCategory.isEmpty {
                        spendingChart
                    }

                    if !transactions.isEmpty {
                        recentSection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(balance, format: .currency(code: currencyCode))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(balance < 0 ? .red : .primary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryCard(title: String, amount: Decimal, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.subheadline)
                .foregroundStyle(tint)
            Text(amount, format: .currency(code: currencyCode))
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month's Spending")
                .font(.headline)

            Chart(spendingByCategory, id: \.category) { item in
                BarMark(
                    x: .value("Amount", NSDecimalNumber(decimal: item.total).doubleValue),
                    y: .value("Category", item.category.label)
                )
                .foregroundStyle(item.category.color.gradient)
                .cornerRadius(4)
            }
            .frame(height: CGFloat(spendingByCategory.count) * 44)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            ForEach(transactions.prefix(5)) { transaction in
                TransactionRow(transaction: transaction)
                if transaction.persistentModelID != transactions.prefix(5).last?.persistentModelID {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
