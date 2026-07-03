import SwiftUI

@main
struct FinanceAppApp: App {
    @StateObject private var store = FinanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
