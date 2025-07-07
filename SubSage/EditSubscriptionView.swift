import SwiftUI

struct EditSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let subscription: SubscriptionEntity

    // State змінні
    @State private var name: String
    @State private var price: String
    @State private var nextBillingDate: Date
    @State private var selectedCategory: SubscriptionCategory // <--- Тип змінено на enum
    @State private var billingCycle: BillingCycle
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var showingIconPicker = false
    @State private var selectedCurrency: Currency
    @State private var isActive: Bool

    // Ініціалізатор, який правильно встановлює початкові значення
    init(subscription: SubscriptionEntity) {
        self.subscription = subscription
        _name = State(initialValue: subscription.name ?? "")
        _price = State(initialValue: String(subscription.price))
        _nextBillingDate = State(initialValue: subscription.nextBilling ?? Date())
        _selectedCategory = State(initialValue: SubscriptionCategory(rawValue: subscription.category ?? "other") ?? .other)
        _billingCycle = State(initialValue: BillingCycle(rawValue: subscription.billingCycle ?? "monthly") ?? .monthly)
        _selectedIcon = State(initialValue: subscription.iconName ?? "dollarsign.circle.fill")
        _selectedColor = State(initialValue: subscription.iconColor ?? "blue")
        _selectedCurrency = State(initialValue: Currency(rawValue: subscription.currency ?? "USD") ?? .usd)
        _isActive = State(initialValue: subscription.isActive)
    }

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
                    
                    // ВИПРАВЛЕНИЙ PICKER ДЛЯ КАТЕГОРІЙ
                    Picker("category", selection: $selectedCategory) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                            Text(category.localizedName).tag(category)
                        }
                    }
                }
                
                Section("payment_details") {
                    DatePicker("next_payment", selection: $nextBillingDate, displayedComponents: .date)
                    
                    // ВИПРАВЛЕНИЙ PICKER ДЛЯ ПЕРІОДИЧНОСТІ
                    Picker("frequency", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.localizedName).tag(cycle)
                        }
                    }
                }
                
                Section("status") {
                    Toggle("active_subscription", isOn: $isActive)
                }
            }
            .navigationTitle("edit_subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveChanges()
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
    
    private func saveChanges() {
        withAnimation {
            subscription.name = name
            subscription.price = Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0
            subscription.currency = selectedCurrency.rawValue
            subscription.nextBilling = nextBillingDate
            // Зберігаємо rawValue, тобто ключ
            subscription.category = selectedCategory.rawValue
            subscription.billingCycle = billingCycle.rawValue
            subscription.iconName = selectedIcon
            subscription.iconColor = selectedColor
            subscription.updatedAt = Date()
            subscription.isActive = isActive
            
            NotificationManager.shared.scheduleNotification(for: subscription)
            
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
