# FinanceApp

A personal finance tracker for iPhone and iPad, built with SwiftUI and Swift Charts.

## Features

- **Overview dashboard** — total balance, this month's income and expenses, a donut chart of spending by category, and recent activity.
- **Transactions** — record income and expenses with a title, amount, date, and category. Search, browse by day, and swipe to delete.
- **Budgets** — set monthly spending limits per category and track progress, with a clear "over budget" warning.
- **Settings** — pick your currency, reload sample data, or erase everything.

Data is saved as JSON in the app's Documents directory, so everything persists between launches with no external dependencies.

## Requirements

- Xcode 16 or later
- iOS 17.0+ deployment target

## Getting Started

1. Clone the repository.
2. Open `FinanceApp.xcodeproj` in Xcode.
3. Select an iPhone simulator and press **Run** (⌘R).

The app ships with sample data on first launch so every screen has something to show. Use **Settings → Erase All Data** to start fresh.

## Project Structure

```
FinanceApp/
├── FinanceAppApp.swift        # App entry point
├── Models/
│   ├── Models.swift           # Transaction, Budget, category & kind enums
│   └── FinanceStore.swift     # Observable store with JSON persistence
└── Views/
    ├── ContentView.swift      # Tab bar
    ├── DashboardView.swift    # Balance, summaries, spending chart
    ├── TransactionsView.swift # Searchable list grouped by day
    ├── AddTransactionView.swift
    ├── BudgetsView.swift      # Budget progress + add budget sheet
    └── SettingsView.swift
```
