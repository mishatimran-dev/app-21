import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount: Decimal?
    @State private var isExpense = true
    @State private var category: Category = .other
    @State private var date: Date = .now
    @State private var note = ""

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && (amount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField(
                        "Amount",
                        value: $amount,
                        format: .currency(code: currencyCode)
                    )
                    .keyboardType(.decimalPad)
                }

                Section("Type") {
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases) { category in
                            Label(category.label, systemImage: category.symbol)
                                .tag(category)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let transaction = Transaction(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount ?? 0,
            date: date,
            category: category,
            isExpense: isExpense,
            note: note
        )
        modelContext.insert(transaction)
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
