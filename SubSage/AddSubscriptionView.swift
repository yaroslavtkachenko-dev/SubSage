import SwiftUI

// Цей enum можна залишити тут або винести в окремий файл
enum NotificationOption: String, CaseIterable, Identifiable {
    case oneDay, twoDays, fiveDays, oneWeek

    var id: String { self.rawValue }

    var localizedName: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
    
    // Повертає кількість днів як число
    var dayValue: Int16 {
        switch self {
        case .oneDay: return 1
        case .twoDays: return 2
        case .fiveDays: return 5
        case .oneWeek: return 7
        }
    }
}

struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var price = ""
    @State private var nextBillingDate = Date()
    @State private var billingCycle: BillingCycle = .monthly
    @State private var selectedCategory: SubscriptionCategory = .other
    @State private var selectedIcon = "dollarsign.circle.fill"
    @State private var selectedColor = "blue"
    @State private var showingIconPicker = false
    @State private var selectedCurrency: Currency = .usd
    @State private var notificationOption: NotificationOption = .twoDays

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
                    
                    // ВИПРАВЛЕНО: Picker для валюти
                    Picker("currency", selection: $selectedCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                    
                    Picker("category", selection: $selectedCategory) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                            Text(category.localizedName).tag(category)
                        }
                    }
                }

                Section("payment_details") {
                    DatePicker("next_payment", selection: $nextBillingDate, displayedComponents: .date)
                    
                    // ВИПРАВЛЕНО: Picker для періодичності
                    Picker("frequency", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.localizedName).tag(cycle)
                        }
                    }
                    
                    Picker("remind_me", selection: $notificationOption) {
                        ForEach(NotificationOption.allCases) { option in
                            Text(option.localizedName).tag(option)
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
            newSubscription.billingCycle = billingCycle.rawValue
            newSubscription.category = selectedCategory.rawValue
            newSubscription.iconName = selectedIcon
            newSubscription.iconColor = selectedColor
            
            // ВИПРАВЛЕНО: Зберігаємо значення з enum
            newSubscription.notificationOffset = -notificationOption.dayValue
            
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
