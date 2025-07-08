import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Binding var selectedColor: String
    
    let icons = [
        // Фінанси
        "dollarsign.circle.fill", "creditcard.fill", "banknote.fill", "cart.fill",
        
        // Медіа та розваги
        "film.fill", "music.note", "gamecontroller.fill", "tv.fill", "headphones",
        
        // Робота та продуктивність
        "briefcase.fill", "doc.text.fill", "calendar", "chart.bar.fill",
        
        // Хмарні сервіси та інтернет
        "cloud.fill", "wifi", "globe", "server.rack",
        
        // Дім та побут
        "house.fill", "lightbulb.fill", "wrench.and.screwdriver.fill",
        
        // Транспорт
        "car.fill", "airplane", "tram.fill",
        
        // Здоров'я та спорт
        "heart.fill", "figure.walk", "pills.fill",
        
        // Інше
        "book.fill", "graduationcap.fill", "pawprint.fill"
    ]
    let colorNames = ["red", "orange", "yellow", "green", "teal", "mint", "cyan", "blue", "indigo", "purple", "pink", "brown", "gray"]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Блок для попереднього перегляду
                    VStack {
                        Text("icon_appearance")
                            .font(.headline)
                        
                        Image(systemName: selectedIcon)
                            .font(.system(size: 60))
                            .foregroundColor(colorFromString(selectedColor))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                    
                    // Блок вибору іконки
                    VStack {
                        Text("choose_icon")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.largeTitle)
                                    .padding()
                                    .background(selectedIcon == icon ? Color.gray.opacity(0.3) : Color.clear)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Блок вибору кольору
                    VStack {
                        Text("choose_color")
                            .font(.headline)
                            .padding(.top)
                        
                        // ВИПРАВЛЕНО ТУТ: Замінено HStack на LazyVGrid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                            ForEach(colorNames, id: \.self) { colorName in
                                Circle()
                                    .fill(colorFromString(colorName))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == colorName ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = colorName
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("icon_settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func colorFromString(_ name: String) -> Color {
        switch name {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "teal": return .teal
        case "mint": return .mint
        case "cyan": return .cyan
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray": return .gray
        default: return .black
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    @State static var icon = "dollarsign.circle.fill"
    @State static var color = "blue"

    static var previews: some View {
        IconPickerView(selectedIcon: $icon, selectedColor: $color)
    }
}
