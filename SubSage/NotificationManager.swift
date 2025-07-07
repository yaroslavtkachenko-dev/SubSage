import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}

    // Запит дозволу
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Дозвіл на сповіщення отримано.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Планування сповіщення
    func scheduleNotification(for subscription: SubscriptionEntity) {
        let content = UNMutableNotificationContent()
        content.title = "Нагадування про оплату"
        let priceString = String(format: "%.2f %@", subscription.price, subscription.currency ?? "USD")
        content.body = "Скоро відбудеться списання \(priceString) за \(subscription.name ?? "підписку")."
        content.sound = .default

        guard let paymentDate = subscription.nextBilling else { return }
        let notificationDate = Calendar.current.date(byAdding: .day, value: -2, to: paymentDate)!
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: subscription.id?.uuidString ?? UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Помилка планування сповіщення: \(error.localizedDescription)")
            } else {
                print("Сповіщення для '\(subscription.name ?? "")' успішно заплановано.")
            }
        }
    }
    
    // Функція скасування, переміщена всередину класу
    func cancelNotification(forSubscriptionID id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Сповіщення зі скасовано ID: \(id)")
    }
}
