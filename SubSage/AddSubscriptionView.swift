import SwiftUI

enum NotificationOption: String, CaseIterable, Identifiable {
    case oneDay, twoDays, fiveDays, oneWeek
    var id: String { self.rawValue }
    var localizedName: LocalizedStringKey { LocalizedStringKey(self.rawValue) }
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
    
    @State private var showingSaveError = false

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
                        ForEach(Currency.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("category", selection: $selectedCategory) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { Text($0.localizedName).tag($0) }
                    }
                }
                Section("payment_details") {
                    DatePicker("next_payment", selection: $nextBillingDate, displayedComponents: .date)
                    Picker("frequency", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { Text($0.localizedName).tag($0) }
                    }
                    Picker("remind_me", selection: $notificationOption) {
                        ForEach(NotificationOption.allCases) { Text($0.localizedName).tag($0) }
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
                    }
                    .disabled(name.isEmpty || price.isEmpty) // Кнопка неактивна, якщо назва або ціна порожні
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
            }
            .alert("error_title", isPresented: $showingSaveError) {
                Button("ok") {}
            } message: {
                Text("save_error_message")
            }
        }
    }
    
    private func saveSubscription() {
        // Валідація ціни
        guard let priceDouble = Double(price.replacingOccurrences(of: ",", with: ".")), priceDouble > 0 else {
            showingSaveError = true
            return
        }

        withAnimation {
            let newSubscription = SubscriptionEntity(context: viewContext)
            newSubscription.id = UUID()
            newSubscription.createdAt = Date()
            newSubscription.updatedAt = Date()
            newSubscription.name = name
            newSubscription.price = priceDouble // Використовуємо перевірене значення
            newSubscription.currency = selectedCurrency.rawValue
            newSubscription.nextBilling = nextBillingDate
            newSubscription.billingCycle = billingCycle.rawValue
            newSubscription.category = selectedCategory.rawValue
            newSubscription.iconName = selectedIcon
            newSubscription.iconColor = selectedColor
            newSubscription.notificationOffset = -notificationOption.dayValue
            
            NotificationManager.shared.scheduleNotification(for: newSubscription)
            
            do {
                try viewContext.save()
                dismiss() // Закриваємо вікно тільки при успішному збереженні
            } catch {
                print("Error saving subscription: \(error.localizedDescription)")
                showingSaveError = true
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
