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
    
    // Нова властивість з приблизними курсами
    var rateComparedToUSD: Double {
        switch self {
        case .usd: return 1.0
        case .eur: return 1.08 // 1 EUR = 1.08 USD
        case .uah: return 0.025 // 1 UAH = 0.025 USD
        case .gbp: return 1.27 // 1 GBP = 1.27 USD
        }
    }
}

enum SubscriptionCategory: String, CaseIterable, Identifiable {
    case entertainment, work, cloud, education, other
    var id: String { self.rawValue }
    var localizedName: LocalizedStringKey { LocalizedStringKey(self.rawValue) }
}

enum IconColor: String, CaseIterable, Identifiable {
    case red, orange, yellow, green, teal, mint, cyan, blue, indigo, purple, pink, brown, gray
    
    var id: String { self.rawValue }
    
    // Властивість, що повертає сам колір
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        case .mint: return .mint
        case .cyan: return .cyan
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        case .gray: return .gray
        }
    }
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
    var iconColor: IconColor? // <--- Змінено тип на enum IconColor

    // Стара функція getIconColor() більше не потрібна
    
    static var example: Subscription {
        Subscription(
            id: UUID(), name: "Apple Music", price: 4.99, currency: .usd,
            nextPaymentDate: Date(), billingCycle: .monthly,
            iconName: "music.note", category: .entertainment, iconColor: .red // <--- Змінено
        )
    }
    
    static var example2: Subscription {
        Subscription(
            id: UUID(), name: "iCloud+", price: 2.99, currency: .usd,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            billingCycle: .monthly, iconName: "icloud.fill", category: .work, iconColor: .blue // <--- Змінено
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
            iconColor: IconColor(rawValue: self.iconColor ?? "blue") // <--- Змінено
        )
    }

    // Оновлена функція з конвертацією
    func monthlyEquivalentPrice() -> Double {
        let currency = Currency(rawValue: self.currency ?? "USD") ?? .usd
        let priceInUSD = self.price * currency.rateComparedToUSD
        
        switch BillingCycle(rawValue: self.billingCycle ?? "monthly") {
        case .monthly:
            return priceInUSD
        case .yearly:
            return priceInUSD / 12
        case .quarterly:
            return priceInUSD / 3
        case .weekly:
            return priceInUSD * 4
        default:
            return 0
        }
    }
}






