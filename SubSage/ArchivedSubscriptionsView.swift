import SwiftUI
import CoreData

struct ArchivedSubscriptionsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.updatedAt, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var archivedSubscriptions: FetchedResults<SubscriptionEntity>
    
    var body: some View {
        // Перевіряємо, чи список порожній
        if archivedSubscriptions.isEmpty {
            VStack {
                Text("archived_empty_state") // Ключ для "Ваш архів порожній"
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("archive")
        } else {
            List {
                ForEach(archivedSubscriptions) { subscriptionEntity in
                    NavigationLink {
                        // Ми можемо редагувати, щоб відновити підписку
                        EditSubscriptionView(subscription: subscriptionEntity)
                    } label: {
                        SubscriptionCardView(subscription: subscriptionEntity.toSubscription())
                            // Робимо неактивні картки напівпрозорими
                            .opacity(0.6)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    // Додаємо свайп для відновлення
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            unarchiveSubscription(subscriptionEntity)
                        } label: {
                            Label("unarchive_action", systemImage: "arrow.uturn.backward.circle.fill")
                        }
                        .tint(.green)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("archive")
        }
    }
    
    // Нова функція для відновлення підписки
    private func unarchiveSubscription(_ subscription: SubscriptionEntity) {
        withAnimation {
            subscription.isActive = true
            subscription.updatedAt = Date()
            try? viewContext.save()
        }
    }
}

struct ArchivedSubscriptionsView_Previews: PreviewProvider {
    static var previews: some View {
        // Додаємо NavigationView тут для коректного прев'ю
        NavigationView {
            ArchivedSubscriptionsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
