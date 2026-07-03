import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var isConfirmingErase = false

    private let currencyCodes = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "INR", "CHF"]

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Picker("Currency", selection: $store.currencyCode) {
                        ForEach(currencyCodes, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                }

                Section("Data") {
                    Button("Load Sample Data") {
                        store.loadSampleData()
                    }
                    Button("Erase All Data", role: .destructive) {
                        isConfirmingErase = true
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Transactions", value: "\(store.transactions.count)")
                    LabeledContent("Budgets", value: "\(store.budgets.count)")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Erase all transactions and budgets?",
                isPresented: $isConfirmingErase,
                titleVisibility: .visible
            ) {
                Button("Erase Everything", role: .destructive) {
                    store.eraseAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(FinanceStore())
}
