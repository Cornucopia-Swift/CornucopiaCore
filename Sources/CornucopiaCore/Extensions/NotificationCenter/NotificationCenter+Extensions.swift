//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension NotificationCenter {

    /// Posts the notification asynchronously on the specified ``queue``.
    func CC_postAsync(on queue: DispatchQueue, name: Notification.Name, object: Any? = nil) {
        queue.async { self.post(name: name, object: object) }
    }
}
