import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    @State private var kind: TransactionKind = .expense
    @State private var title = ""
    @State private var amountText = ""
    @State private var date = Date.now
    @State private var category: TransactionCategory = .groceries

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }

    private var isValid: Bool {
        guard let amount else { return false }
        return amount > 0 && !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $kind) {
                        ForEach(TransactionKind.allCases) { kind in
                            Text(kind.label).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCategory.categories(for: kind)) { category in
                            Label(category.label, systemImage: category.symbol)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTransaction() }
                        .disabled(!isValid)
                }
            }
            .onChange(of: kind) { _, newKind in
                if !TransactionCategory.categories(for: newKind).contains(category) {
                    category = newKind == .income ? .salary : .groceries
                }
            }
        }
    }

    private func saveTransaction() {
        guard let amount else { return }
        let transaction = Transaction(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            date: date,
            category: category,
            kind: kind
        )
        store.add(transaction)
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(FinanceStore())
}
