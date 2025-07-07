import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Створюємо два приклади підписки
        let example1 = SubscriptionEntity(context: viewContext)
        example1.id = UUID()
        example1.name = "Apple Music"
        example1.price = 4.99
        example1.currency = "USD"
        example1.billingCycle = BillingCycle.monthly.rawValue // ВИПРАВЛЕНО
        example1.createdAt = Date()
        example1.nextBilling = Date()

        let example2 = SubscriptionEntity(context: viewContext)
        example2.id = UUID()
        example2.name = "iCloud+"
        example2.price = 2.99
        example2.currency = "USD"
        example2.billingCycle = BillingCycle.monthly.rawValue // ВИПРАВЛЕНО
        example2.createdAt = Date()
        example2.nextBilling = Date()
        
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
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
