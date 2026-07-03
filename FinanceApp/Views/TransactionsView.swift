import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var searchText = ""
    @State private var isAddingTransaction = false

    private var filteredTransactions: [Transaction] {
        guard !searchText.isEmpty else { return store.transactions }
        return store.transactions.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.category.label.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedTransactions: [(day: Date, items: [Transaction])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filteredTransactions) {
            calendar.startOfDay(for: $0.date)
        }
        return groups.keys.sorted(by: >).map { day in
            (day: day, items: (groups[day] ?? []).sorted { $0.date > $1.date })
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.transactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Tap + to record your first transaction.")
                    )
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.day) { group in
                            Section(group.day.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(group.items) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                                .onDelete { offsets in
                                    store.remove(group.items, at: offsets)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search transactions")
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingTransaction) {
                AddTransactionView()
            }
        }
    }
}

struct TransactionRow: View {
    @EnvironmentObject private var store: FinanceStore
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.symbol)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(transaction.category.color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.body)
                    .lineLimit(1)
                Text(transaction.category.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaction.signedAmount, format: .currency(code: store.currencyCode))
                .font(.body.monospacedDigit())
                .foregroundStyle(transaction.kind == .income ? Color.green : Color.primary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TransactionsView()
        .environmentObject(FinanceStore())
}
