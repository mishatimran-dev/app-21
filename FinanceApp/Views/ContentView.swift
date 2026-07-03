import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Overview", systemImage: "chart.pie.fill")
                }

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle.fill")
                }

            BudgetsView()
                .tabItem {
                    Label("Budgets", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FinanceStore())
}
