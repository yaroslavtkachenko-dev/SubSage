import SwiftUI
import Charts

struct AnalyticsView: View {
    
    // Запит до бази даних для отримання всіх підписок
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.price, ascending: false)],
        predicate: NSPredicate(format: "isActive == YES"), // Показуємо аналітику тільки для активних підписок
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionEntity>


    // Готує дані для стовпчикової діаграми, конвертуючи ціни в місячний еквівалент
    private var barChartData: [SubscriptionMonthlyValue] {
        subscriptions
            .filter { $0.price > 0 }
            .map { sub in
                SubscriptionMonthlyValue(
                    name: sub.name ?? "N/A",
                    monthlyPriceUSD: sub.monthlyEquivalentPrice()
                )
            }
            .sorted { $0.monthlyPriceUSD > $1.monthlyPriceUSD }
    }
    
    // Готує дані для кругової діаграми, групуючи витрати по категоріях
    private var spendingByCategory: [(category: String, amount: Double)] {
        let dictionary = Dictionary(grouping: subscriptions) {
            SubscriptionCategory(rawValue: $0.category ?? "other")?.localizedName.stringKey ?? "Інше"
        }
        .mapValues { subscriptions in
            subscriptions.reduce(0) { total, sub in
                total + sub.monthlyEquivalentPrice()
            }
        }
        
        let categoryArray = dictionary.map { (category, amount) in
            return (category: category, amount: amount)
        }
        return categoryArray.sorted { $0.amount > $1.amount }
    }

    // Розраховує загальні місячні витрати, конвертуючи всі валюти в USD
    private var totalMonthlySpend: Double {
        subscriptions.reduce(0) { total, subscription in
            total + subscription.monthlyEquivalentPrice()
        }
    }

    // --- ІНТЕРФЕЙС ---
    
    var body: some View {
        NavigationView {
            // Показуємо повідомлення, якщо немає жодної підписки
            if subscriptions.isEmpty {
                VStack {
                    Text("add_subscription_to_see_analytics")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("analytics")
            } else {
                // Основний вміст з графіками
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Блок із загальною сумою
                        VStack(alignment: .leading) {
                            Text("monthly_spend")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f %@", totalMonthlySpend, Currency.usd.symbol))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding([.horizontal, .top])

                        // Кругова діаграма "Витрати по категоріях"
                        if !spendingByCategory.isEmpty && totalMonthlySpend > 0 {
                            VStack(alignment: .leading) {
                                Text("spending_by_category")
                                    .font(.headline)
                                Chart(spendingByCategory, id: \.category) { item in
                                    SectorMark(
                                        angle: .value("Сума", item.amount),
                                        innerRadius: .ratio(0.6)
                                    )
                                    .foregroundStyle(by: .value("Категорія", item.category))
                                    .annotation(position: .overlay) {
                                        // Розраховуємо відсоток, перевіряючи, чи не дорівнює totalMonthlySpend нулю
                                        let percentage = totalMonthlySpend > 0 ? (item.amount / totalMonthlySpend * 100) : 0
                                        
                                        // Показуємо відсоток, тільки якщо він значущий
                                        if percentage > 1 {
                                            Text(String(format: "%.0f%%", percentage))
                                                .font(.caption)
                                                .bold()
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .frame(height: 250)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Стовпчикова діаграма "Витрати по підписках"
                        if !barChartData.isEmpty {
                            VStack(alignment: .leading) {
                                Text("spending_by_subscription")
                                    .font(.headline)
                                Chart(barChartData) { subValue in
                                    BarMark(
                                        x: .value("Назва", subValue.name),
                                        y: .value("Місячна ціна (USD)", subValue.monthlyPriceUSD)
                                    )
                                    .foregroundStyle(by: .value("Назва", subValue.name))
                                }
                                .frame(height: 250)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
                .navigationTitle("analytics")
            }
        }
    }
}

// Допоміжна структура для даних стовпчикової діаграми
struct SubscriptionMonthlyValue: Identifiable {
    var id = UUID()
    var name: String
    var monthlyPriceUSD: Double
}

// Потрібно додати нову властивість до LocalizedStringKey для зручності
extension LocalizedStringKey {
    var stringKey: String {
        let mirror = Mirror(reflecting: self)
        let key = mirror.children.first(where: { $0.label == "key" })?.value as? String
        return key ?? ""
    }
}

// Preview
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
