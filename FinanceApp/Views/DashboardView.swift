import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject private var store: FinanceStore

    private var month: Date { .now }

    private var spending: [(category: TransactionCategory, total: Double)] {
        store.spendingByCategory(in: month)
    }

    private var recentTransactions: [Transaction] {
        Array(store.transactions.sorted { $0.date > $1.date }.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard

                    HStack(spacing: 16) {
                        summaryCard(
                            title: "Income",
                            amount: store.income(in: month),
                            color: .green,
                            symbol: "arrow.down.circle.fill"
                        )
                        summaryCard(
                            title: "Expenses",
                            amount: store.expenses(in: month),
                            color: .red,
                            symbol: "arrow.up.circle.fill"
                        )
                    }

                    spendingCard
                    recentCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(store.balance, format: .currency(code: store.currencyCode))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(store.balance >= 0 ? Color.primary : Color.red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryCard(title: String, amount: Double, color: Color, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: symbol)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(amount, format: .currency(code: store.currencyCode))
                .font(.title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var spendingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending This Month")
                .font(.headline)

            if spending.isEmpty {
                Text("No expenses recorded this month yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(spending, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.total),
                        innerRadius: .ratio(0.62),
                        angularInset: 1.5
                    )
                    .cornerRadius(4)
                    .foregroundStyle(item.category.color)
                }
                .frame(height: 220)

                VStack(spacing: 8) {
                    ForEach(spending, id: \.category) { item in
                        HStack {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 10, height: 10)
                            Text(item.category.label)
                                .font(.subheadline)
                            Spacer()
                            Text(item.total, format: .currency(code: store.currencyCode))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var recentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)

            if recentTransactions.isEmpty {
                Text("No transactions yet. Add one from the Transactions tab.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(recentTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                    if transaction.id != recentTransactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardView()
        .environmentObject(FinanceStore())
}
