import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationView {
            Form {
                Section("my_data") { // Ключ для "Мої дані"
                    NavigationLink {
                        ArchivedSubscriptionsView()
                    } label: {
                        Text("archive") // Ключ для "Архів підписок"
                    }
                }
                
                Section("settings") { // Ключ для "Налаштування"
                    Text("app_version") // Ключ для "Версія застосунку: 1.0"
                    Text("notifications_status") // Ключ для "Сповіщення: вимкнені"
                }
                
                Section("information") { // Ключ для "Інформація"
                    Text("privacy_policy") // Ключ для "Політика конфіденційності"
                    Text("terms_conditions") // Ключ для "Правила та умови"
                }
            }
            .navigationTitle("account") // Ключ для "Акаунт"
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
