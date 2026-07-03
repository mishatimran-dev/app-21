import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(transaction.category.color.gradient)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(transaction.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaction.signedAmount, format: .currency(code: currencyCode))
                .font(.body.weight(.semibold))
                .foregroundStyle(transaction.isExpense ? .primary : Color.green)
        }
    }
}
