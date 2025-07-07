import SwiftUI
import CoreData

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

struct SubscriptionsListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionEntity>

    @State private var showingAddView = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(subscriptions) { subscriptionEntity in
                    NavigationLink {
                        EditSubscriptionView(subscription: subscriptionEntity)
                    } label: {
                        SubscriptionCardView(subscription: subscriptionEntity.toSubscription())
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteSubscription(subscriptionEntity)
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
                }
            }
            .listStyle(.plain)
            .navigationTitle("my_subscriptions")
            .searchable(text: $searchText, prompt: Text("search_subscriptions_placeholder"))
            .onChange(of: searchText) {
                if searchText.isEmpty {
                    subscriptions.nsPredicate = NSPredicate(format: "isActive == YES")
                } else {
                    subscriptions.nsPredicate = NSPredicate(format: "name CONTAINS[c] %@ AND isActive == YES", searchText)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddView = true } label: { Label("add_item_action", systemImage: "plus") }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddSubscriptionView().environment(\.managedObjectContext, self.viewContext)
            }
        }
    }

    private func archiveSubscription(_ subscription: SubscriptionEntity) {
        withAnimation {
            subscription.isActive = false
            subscription.updatedAt = Date()
            try? viewContext.save()
        }
    }
    
    private func deleteSubscription(_ subscription: SubscriptionEntity) {
        withAnimation {
            if let id = subscription.id?.uuidString {
                NotificationManager.shared.cancelNotification(forSubscriptionID: id)
            }
            viewContext.delete(subscription)
            try? viewContext.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
