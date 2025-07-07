import SwiftUI
import CoreData

struct ArchivedSubscriptionsView: View {
    // Запит до бази даних, який вибирає тільки НЕАКТИВНІ підписки
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.updatedAt, ascending: false)],
        predicate: NSPredicate(format: "isActive == NO"),
        animation: .default)
    private var archivedSubscriptions: FetchedResults<SubscriptionEntity>
    
    var body: some View {
        // Ми не додаємо NavigationView, оскільки перейдемо на цей екран з іншого
        List {
            ForEach(archivedSubscriptions) { subscriptionEntity in
                NavigationLink {
                    // Ми можемо редагувати, щоб відновити підписку
                    EditSubscriptionView(subscription: subscriptionEntity)
                } label: {
                    SubscriptionCardView(subscription: subscriptionEntity.toSubscription())
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("archive") // <--- Змінено на ключ локалізації
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
