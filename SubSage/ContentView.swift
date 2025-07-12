import SwiftUI
import CoreData

// Головний View, який містить панель вкладок
struct ContentView: View {
    var body: some View {
        TabView {
            SubscriptionsListView()
                .tabItem {
                    Label("subscriptions", systemImage: "list.bullet")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("analytics", systemImage: "chart.pie.fill")
                }
            
            AccountView()
                .tabItem {
                    Label("account", systemImage: "person.crop.circle")
                }
        }
    }
}

// View, що відповідає за відображення списку активних підписок
struct SubscriptionsListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var subscriptions: [SubscriptionEntity] = []
    
    @State private var showingAddView = false
    @State private var searchText = ""
    
    @State private var showingDeleteConfirmation = false
    @State private var subscriptionToDelete: SubscriptionEntity?

    var body: some View {
        NavigationView {
            
            
            // Перевіряємо, чи список порожній
            if subscriptions.isEmpty && searchText.isEmpty {
                VStack {
                    Text("subscriptions_empty_state")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("my_subscriptions")
            } else {
                List {
                    ForEach(subscriptions) { subscriptionEntity in
                        NavigationLink {
                            EditSubscriptionView(subscription: subscriptionEntity)
                        } label: {
                            HStack {
                                if subscriptionEntity.isPinned {
                                    Image(systemName: "pin.fill")
                                        .foregroundColor(.yellow)
                                        .padding(.trailing, -10)
                                }
                                SubscriptionCardView(subscription: subscriptionEntity.toSubscription())
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                subscriptionToDelete = subscriptionEntity
                                showingDeleteConfirmation = true
                            } label: {
                                Label("delete", systemImage: "trash.fill")
                            }
                            Button {
                                archiveSubscription(subscriptionEntity)
                            } label: {
                                Label("archive_action", systemImage: "archivebox.fill")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                togglePin(for: subscriptionEntity)
                            } label: {
                                Label(subscriptionEntity.isPinned ? "unpin_action" : "pin_action",
                                      systemImage: subscriptionEntity.isPinned ? "pin.slash.fill" : "pin.fill")
                            }
                            .tint(.yellow)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("my_subscriptions")
            }
        }
        .searchable(text: $searchText, prompt: Text("search_subscriptions_placeholder"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingAddView = true } label: { Label("add_item_action", systemImage: "plus") }
            }
        }
        .sheet(isPresented: $showingAddView) {
            AddSubscriptionView().environment(\.managedObjectContext, self.viewContext)
        }
        .alert("delete_confirmation_title", isPresented: $showingDeleteConfirmation, presenting: subscriptionToDelete) { subscription in
            Button("delete", role: .destructive) {
                deleteSubscription(subscription)
            }
        } message: { subscription in
            Text(.init(String(format: NSLocalizedString("delete_confirmation_message", comment: ""), subscription.name ?? "N/A")))
        }
        .onAppear {
            fetchSubscriptions(with: searchText)
        }
        .onChange(of: searchText) {
            fetchSubscriptions(with: searchText)
        }
        .onChange(of: showingAddView) {
             if !showingAddView {
                fetchSubscriptions(with: searchText)
            }
        }
    }
    
    
    private func fetchSubscriptions(with searchText: String = "") {
        let request = NSFetchRequest<SubscriptionEntity>(entityName: "SubscriptionEntity")
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SubscriptionEntity.isPinned, ascending: false),
            NSSortDescriptor(keyPath: \SubscriptionEntity.createdAt, ascending: false)
        ]
        
        if searchText.isEmpty {
            request.predicate = NSPredicate(format: "isActive == YES")
        } else {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@ AND isActive == YES", searchText)
        }
        
        do {
            subscriptions = try viewContext.fetch(request)
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            subscriptions = []
        }
    }
    
    private func archiveSubscription(_ subscription: SubscriptionEntity) {
        withAnimation {
            subscription.isActive = false
            subscription.updatedAt = Date()
            try? viewContext.save()
            fetchSubscriptions(with: searchText)
        }
    }
    
    private func deleteSubscription(_ subscription: SubscriptionEntity) {
        withAnimation {
            if let id = subscription.id?.uuidString {
                NotificationManager.shared.cancelNotification(forSubscriptionID: id)
            }
            viewContext.delete(subscription)
            try? viewContext.save()
            fetchSubscriptions(with: searchText)
        }
    }

    private func togglePin(for subscription: SubscriptionEntity) {
        withAnimation {
            subscription.isPinned.toggle()
            subscription.updatedAt = Date()
            try? viewContext.save()
            fetchSubscriptions(with: searchText)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
