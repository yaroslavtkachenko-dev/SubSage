import Foundation
import SwiftUI

enum BillingCycle: String, CaseIterable, Identifiable {
    case monthly, yearly, weekly, quarterly
    var id: String { self.rawValue }
    var localizedName: LocalizedStringKey { LocalizedStringKey(self.rawValue) }
}

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case uah = "UAH"
    case gbp = "GBP"
    var id: String { self.rawValue }
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .uah: return "₴"
        case .gbp: return "£"
        }
    }
}

enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case entertainment, work, cloud, education, other
    var id: String { self.rawValue }
    var localizedName: LocalizedStringKey { LocalizedStringKey(self.rawValue) }
}

struct Subscription: Identifiable {
    let id: UUID
    var name: String
    var price: Double
    var currency: Currency
    var nextPaymentDate: Date
    var billingCycle: BillingCycle
    var notes: String?
    var iconName: String?
    var category: SubscriptionCategory
    var iconColor: String?
    
    func getIconColor() -> Color {
        switch self.iconColor ?? "blue" {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "gray": return .gray
        default: return .blue
        }
    }
    
    static var example: Subscription {
        Subscription(
            id: UUID(), name: "Apple Music", price: 4.99, currency: .usd,
            nextPaymentDate: Date(), billingCycle: .monthly,
            iconName: "music.note", category: .entertainment, iconColor: "red"
        )
    }
    
    static var example2: Subscription {
        Subscription(
            id: UUID(), name: "iCloud+", price: 2.99, currency: .usd,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            billingCycle: .monthly, iconName: "icloud.fill", category: .work, iconColor: "blue"
        )
    }
}

extension SubscriptionEntity {
    func toSubscription() -> Subscription {
        Subscription(
            id: self.id ?? UUID(),
            name: self.name ?? "Без назви",
            price: self.price,
            currency: Currency(rawValue: self.currency ?? "USD") ?? .usd,
            nextPaymentDate: self.nextBilling ?? Date(),
            billingCycle: BillingCycle(rawValue: self.billingCycle ?? "monthly") ?? .monthly,
            notes: self.note,
            iconName: self.iconName,
            category: SubscriptionCategory(rawValue: self.category ?? "other") ?? .other,
            iconColor: self.iconColor
        )
    }
    
    func monthlyEquivalentPrice() -> Double {
        switch BillingCycle(rawValue: self.billingCycle ?? "monthly") {
        case .monthly:
            return self.price
        case .yearly:
            return self.price / 12
        case .quarterly:
            return self.price / 3
        case .weekly:
            return self.price * 4
        default:
            return 0
        }
    }
}
