import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Створюємо приклади для прев'ю
        let example1 = SubscriptionEntity(context: viewContext)
        example1.id = UUID()
        example1.name = "Apple Music"
        example1.price = 4.99
        example1.currency = "USD"
        example1.billingCycle = "monthly"
        example1.category = "entertainment"
        example1.iconName = "music.note"
        example1.iconColor = "red"
        example1.isActive = true
        example1.notificationOffset = -2
        example1.createdAt = Date()
        example1.nextBilling = Date()
        example1.updatedAt = Date()

        let example2 = SubscriptionEntity(context: viewContext)
        example2.id = UUID()
        example2.name = "iCloud+"
        example2.price = 2.99
        example2.currency = "USD"
        example2.billingCycle = "monthly"
        example2.category = "cloud"
        example2.iconName = "icloud.fill"
        example2.iconColor = "blue"
        example2.isActive = true
        example2.notificationOffset = -2
        example2.createdAt = Date()
        example2.nextBilling = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        example2.updatedAt = Date()
        
        
            let archivedExample = SubscriptionEntity(context: viewContext)
            archivedExample.id = UUID()
            archivedExample.name = "Archived Service"
            archivedExample.price = 15.00
            archivedExample.currency = "EUR"
            archivedExample.billingCycle = "yearly"
            archivedExample.category = "other"
            archivedExample.iconName = "archivebox.circle.fill"
            archivedExample.iconColor = "gray"
            archivedExample.isActive = false // Головна відмінність
            archivedExample.notificationOffset = -2
            archivedExample.createdAt = Date()
            archivedExample.nextBilling = Date()
            archivedExample.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SubSage")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Безпечна обробка помилки для релізної версії
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                print("CoreData error: \(error), \(error.userInfo)")
                #endif
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
