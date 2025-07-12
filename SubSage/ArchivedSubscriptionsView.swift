import SwiftUI
import CoreData

struct ArchivedSubscriptionsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.updatedAt, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var archivedSubscriptions: FetchedResults<SubscriptionEntity>
    
    // Нові стани для підтвердження видалення
    @State private var showingDeleteConfirmation = false
    @State private var subscriptionToDelete: SubscriptionEntity?
    
    var body: some View {
        if archivedSubscriptions.isEmpty {
            VStack {
                Text("archived_empty_state")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("archive")
        } else {
            List {
                ForEach(archivedSubscriptions) { subscriptionEntity in
                    NavigationLink {
                        EditSubscriptionView(subscription: subscriptionEntity)
                    } label: {
                        SubscriptionCardView(subscription: subscriptionEntity.toSubscription())
                            .opacity(0.6)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            unarchiveSubscription(subscriptionEntity)
                        } label: {
                            Label("unarchive_action", systemImage: "arrow.uturn.backward.circle.fill")
                        }
                        .tint(.green)
                    }
                    // Нова свайп-дія для повного видалення
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            subscriptionToDelete = subscriptionEntity
                            showingDeleteConfirmation = true
                        } label: {
                            Label("delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("archive")
            // Нове вікно підтвердження видалення
            .alert("delete_confirmation_title", isPresented: $showingDeleteConfirmation, presenting: subscriptionToDelete) { subscription in
                Button("delete", role: .destructive) {
                    deleteSubscription(subscription)
                }
            } message: { subscription in
                Text(.init(String(format: NSLocalizedString("delete_confirmation_message", comment: ""), subscription.name ?? "N/A")))
            }
        }
    }
    
    private func unarchiveSubscription(_ subscription: SubscriptionEntity) {
        withAnimation {
            subscription.isActive = true
            subscription.updatedAt = Date()
            try? viewContext.save()
        }
    }
    
    // Нова функція для повного видалення
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

struct ArchivedSubscriptionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArchivedSubscriptionsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
