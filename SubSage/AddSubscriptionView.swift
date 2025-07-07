import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    // Змінюємо State, щоб працювати з enum, а не з рядками
    @State private var name = ""
    @State private var price = ""
    @State private var nextBillingDate = Date()
    @State private var billingCycle: BillingCycle = .monthly
    @State private var selectedCategory: SubscriptionCategory = .other
    
    @State private var selectedIcon = "dollarsign.circle.fill"
    @State private var selectedColor = "blue"
    @State private var showingIconPicker = false
    @State private var selectedCurrency: Currency = .usd

    var body: some View {
        NavigationView {
            Form {
                Section("icon_section_title") {
                    HStack {
                        Text("icon_appearance")
                        Spacer()
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(colorFromString(selectedColor))
                        Button("choose") { showingIconPicker = true }
                            .buttonStyle(.bordered)
                    }
                }

                Section("subscription_info") {
                    TextField("name_placeholder", text: $name)
                    
                    TextField("price", text: $price)
                        .keyboardType(.decimalPad)

                    Picker("currency", selection: $selectedCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                    
                    // Виправлений Picker для Категорій
                    Picker("category", selection: $selectedCategory) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                            // Використовуємо .localizedName для відображення перекладу
                            Text(category.localizedName).tag(category)
                        }
                    }
                }

                Section("payment_details") {
                    DatePicker("next_payment", selection: $nextBillingDate, displayedComponents: .date)
                    Picker("frequency", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.localizedName).tag(cycle)
                        }
                    }
                }
            }
            .navigationTitle("new_subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveSubscription()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
            }
        }
    }
    
    private func saveSubscription() {
        withAnimation {
            let newSubscription = SubscriptionEntity(context: viewContext)
            newSubscription.id = UUID()
            newSubscription.createdAt = Date()
            newSubscription.updatedAt = Date()
            
            newSubscription.name = name
            newSubscription.price = Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0
            newSubscription.currency = selectedCurrency.rawValue
            newSubscription.nextBilling = nextBillingDate
            // Зберігаємо rawValue, тобто ключ
            newSubscription.billingCycle = billingCycle.rawValue
            newSubscription.category = selectedCategory.rawValue
            newSubscription.iconName = selectedIcon
            newSubscription.iconColor = selectedColor
            
            NotificationManager.shared.scheduleNotification(for: newSubscription)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func colorFromString(_ name: String) -> Color {
        switch name {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "gray": return .gray
        default: return .black
        }
    }
}

struct AddSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubscriptionView()
    }
}
