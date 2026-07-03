# Ledgerly — Simple Finance App for iOS

A simple personal finance tracker built with **SwiftUI**, **SwiftData**, and **Swift Charts**. Track income and expenses, browse and search transactions, and see a live dashboard with your balance, monthly totals, and spending by category.

- **Dashboard** — total balance, this month's income and expenses, spending-by-category chart, recent activity
- **Transactions** — searchable list, swipe to delete, add income/expense with category, date, and notes
- **On-device persistence** via SwiftData (no account, no server, no data leaves the phone)

**Requirements:** Xcode 16+, iOS 17+ deployment target. No third-party dependencies.

## Run it locally

1. Clone the repo and open `FinanceApp.xcodeproj` in Xcode.
2. Pick an iPhone simulator and press **Run** (⌘R).

## Build (CI)

Every push runs `.github/workflows/ios-build.yml`, which compiles the app for the iOS Simulator on a macOS runner — no signing required. This keeps the project always-buildable.

## Deploy & Ship to the App Store

Shipping requires an [Apple Developer Program](https://developer.apple.com/programs/) membership ($99/year). One-time setup:

### 1. One-time Apple setup

1. Enroll at [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll/).
2. In Xcode → project **FinanceApp** → target **FinanceApp** → *Signing & Capabilities*: check **Automatically manage signing** and select your team. If the bundle ID `com.mishatimran.ledgerly` is taken, change it to something unique you own.
3. In [App Store Connect](https://appstoreconnect.apple.com) → *My Apps* → **+** → *New App*: platform iOS, name **Ledgerly** (or your choice), your bundle ID, and an SKU (e.g. `ledgerly-001`).
4. Add a 1024×1024 app icon: drop a PNG into `FinanceApp/Assets.xcassets/AppIcon.appiconset` in Xcode (single-size icon; Xcode generates the rest).

### 2. Ship from Xcode (simplest path)

1. Select **Any iOS Device (arm64)** as the destination.
2. **Product → Archive**, then in the Organizer click **Distribute App → App Store Connect → Upload**.
3. In App Store Connect, the build appears under **TestFlight** after processing (~15 min). Test it on your phone via the TestFlight app.
4. When ready: App Store Connect → your app → **App Store** tab → fill in screenshots, description, privacy details (this app collects no data — declare "Data Not Collected") → select the build → **Submit for Review**.

### 3. Or ship from GitHub Actions (automated)

`.github/workflows/testflight-release.yml` archives, signs, and uploads to TestFlight when triggered manually from the Actions tab. It needs these repository secrets (see the comments at the top of the workflow file for details):

| Secret | What it is |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | Apple Distribution `.p12`, base64-encoded |
| `P12_PASSWORD` | Password for the `.p12` |
| `PROVISIONING_PROFILE_BASE64` | App Store provisioning profile named `Ledgerly App Store`, base64-encoded |
| `KEYCHAIN_PASSWORD` | Any random string |
| `APPLE_TEAM_ID` | Your 10-character team ID |
| `APPSTORE_API_KEY_ID` / `APPSTORE_API_ISSUER_ID` / `APPSTORE_API_PRIVATE_KEY` | App Store Connect API key (Users and Access → Integrations) |

Certificates and profiles are created at [developer.apple.com/account/resources](https://developer.apple.com/account/resources). Never commit signing material — `.gitignore` already blocks it.

## Project layout

```
FinanceApp.xcodeproj/        Xcode project (Xcode 16 buildable-folder format)
FinanceApp/
  FinanceAppApp.swift        App entry point, SwiftData container
  Models/Transaction.swift   SwiftData model + Category enum
  Views/
    ContentView.swift        Tab bar
    DashboardView.swift      Balance, monthly summary, category chart
    TransactionsListView.swift  Searchable list with delete
    AddTransactionView.swift Add income/expense form
    TransactionRow.swift     Shared row component
.github/workflows/           CI build + TestFlight release
ExportOptions.plist          App Store export configuration
```
