import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Binding var selectedColor: String
    
    let icons = ["dollarsign.circle.fill", "creditcard.fill", "film.fill", "music.note", "gamecontroller.fill", "book.fill", "cloud.fill", "car.fill"]
    let colorNames = ["red", "orange", "yellow", "green", "blue", "purple", "pink", "gray"]
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
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
                    .padding()

                    Text("choose_color")
                        .font(.headline)
                        .padding(.top)

                    HStack {
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
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
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
