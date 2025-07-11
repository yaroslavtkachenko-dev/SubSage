import SwiftUI

struct SubscriptionCardView: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: subscription.iconName ?? "dollarsign.circle.fill")
                .font(.title2)
                .frame(width: 45, height: 45)
                // Використовуємо нову властивість .color
                .background((subscription.iconColor?.color ?? .blue).opacity(0.2))
                .clipShape(Circle())
                // І тут також
                .foregroundColor(subscription.iconColor?.color ?? .blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                
                Text(subscription.category.localizedName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.2f %@", subscription.price, subscription.currency.symbol))
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

struct SubscriptionCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SubscriptionCardView(subscription: Subscription.example)
            SubscriptionCardView(subscription: Subscription.example2)
        }
        .padding()
    }
}
