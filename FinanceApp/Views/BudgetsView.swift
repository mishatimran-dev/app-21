import SwiftUI

struct BudgetsView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var isAddingBudget = false

    var body: some View {
        NavigationStack {
            Group {
                if store.budgets.isEmpty {
                    ContentUnavailableView(
                        "No Budgets",
                        systemImage: "chart.bar",
                        description: Text("Tap + to set a monthly spending limit for a category.")
                    )
                } else {
                    List {
                        ForEach(store.budgets) { budget in
                            BudgetRow(budget: budget)
                        }
                        .onDelete { offsets in
                            store.removeBudgets(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingBudget) {
                AddBudgetView()
            }
        }
    }
}

struct BudgetRow: View {
    @EnvironmentObject private var store: FinanceStore
    let budget: Budget

    private var spent: Double {
        store.spending(on: budget.category, in: .now)
    }

    private var progress: Double {
        guard budget.monthlyLimit > 0 else { return 0 }
        return min(spent / budget.monthlyLimit, 1)
    }

    private var isOverBudget: Bool {
        spent > budget.monthlyLimit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(budget.category.label, systemImage: budget.category.symbol)
                    .foregroundStyle(budget.category.color)
                    .font(.headline)
                Spacer()
                if isOverBudget {
                    Text("Over budget")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                }
            }

            ProgressView(value: progress)
                .tint(isOverBudget ? .red : budget.category.color)

            HStack {
                Text(spent, format: .currency(code: store.currencyCode))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(isOverBudget ? .red : .secondary)
                Spacer()
                Text("of \(budget.monthlyLimit, format: .currency(code: store.currencyCode))")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddBudgetView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    @State private var category: TransactionCategory = .groceries
    @State private var limitText = ""

    private var limit: Double? {
        Double(limitText.replacingOccurrences(of: ",", with: "."))
    }

    private var isValid: Bool {
        guard let limit else { return false }
        return limit > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $category) {
                    ForEach(TransactionCategory.categories(for: .expense)) { category in
                        Label(category.label, systemImage: category.symbol)
                            .tag(category)
                    }
                }
                .pickerStyle(.navigationLink)

                TextField("Monthly limit", text: $limitText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let limit {
                            store.setBudget(limit, for: category)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    BudgetsView()
        .environmentObject(FinanceStore())
}
