import SwiftUI
import Charts

struct AnalyticsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.price, ascending: false)],
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionEntity>

    // Властивість для відфільтрованих даних для стовпчикової діаграми
    private var chartData: [SubscriptionEntity] {
        subscriptions.filter { $0.price > 0 }
    }
    
    // Нова властивість для групування витрат по категоріях
    private var spendingByCategory: [(category: String, amount: Double)] {
        let dictionary = Dictionary(grouping: subscriptions) { $0.category ?? "Інше" }
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

    // Обчислення загальної суми
    private var totalMonthlySpend: Double {
        subscriptions.reduce(0) { total, subscription in
            total + subscription.monthlyEquivalentPrice()
        }
    }

    var body: some View {
        NavigationView {
            if subscriptions.isEmpty {
                Text("add_subscription_to_see_analytics")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .navigationTitle("analytics")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading) {
                            Text("monthly_spend")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f %@", totalMonthlySpend, Currency.usd.symbol))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding([.horizontal, .top])

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
                                        if totalMonthlySpend > 0 {
                                            Text(String(format: "%.0f%%", item.amount / totalMonthlySpend * 100))
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
                        
                        if !chartData.isEmpty {
                            VStack(alignment: .leading) {
                                Text("spending_by_subscription")
                                    .font(.headline)
                                Chart(chartData) { sub in
                                    BarMark(
                                        x: .value("Назва", sub.name ?? "N/A"),
                                        y: .value("Ціна", sub.price)
                                    )
                                    .foregroundStyle(by: .value("Назва", sub.name ?? "N/A"))
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


struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
