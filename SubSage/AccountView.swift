import SwiftUI

struct AccountView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    @State private var notificationsEnabled = true

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        ArchivedSubscriptionsView()
                    } label: {
                        Label("archive", systemImage: "archivebox.fill")
                    }
                } header: {
                    Text("my_data")
                }

                Section {
                    
                    HStack {
                        Label("app_version_title", systemImage: "info.circle.fill")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle(isOn: $notificationsEnabled) {
                        Label("notifications_status", systemImage: "bell.fill")
                    }
                } header: {
                    Text("settings")
                }

                Section {
                    Label("privacy_policy", systemImage: "lock.shield.fill")
                    Label("terms_conditions", systemImage: "doc.text.fill")
                } header: {
                    Text("information")
                }
            }
            .navigationTitle("account")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
