import SwiftUI

struct EditSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let subscription: SubscriptionEntity
    
    // State змінні
    @State private var name: String
    @State private var price: String
    @State private var nextBillingDate: Date
    @State private var selectedCategory: SubscriptionCategory
    @State private var billingCycle: BillingCycle
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var showingIconPicker = false
    @State private var selectedCurrency: Currency
    @State private var isActive: Bool
    @State private var notificationOption: NotificationOption
    
    @State private var showingSaveError = false
    
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
        _notificationOption = State(initialValue: NotificationOption(rawValue: String(abs(subscription.notificationOffset))) ?? .twoDays)
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
                
                Section("status") {
                    Toggle("active_subscription", isOn: $isActive)
                }
            }
            .navigationTitle("edit_subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
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
    
    private func saveChanges() {
        guard let priceDouble = Double(price.replacingOccurrences(of: ",", with: ".")), priceDouble > 0 else {
            showingSaveError = true
            return
        }
        
        withAnimation {
            subscription.name = name
            subscription.price = priceDouble
            subscription.currency = selectedCurrency.rawValue
            subscription.nextBilling = nextBillingDate
            subscription.category = selectedCategory.rawValue
            subscription.billingCycle = billingCycle.rawValue
            subscription.iconName = selectedIcon
            subscription.iconColor = selectedColor
            subscription.updatedAt = Date()
            subscription.isActive = isActive
            subscription.notificationOffset = -notificationOption.dayValue
            
            NotificationManager.shared.scheduleNotification(for: subscription)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                print("Error saving changes: \(error.localizedDescription)")
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
