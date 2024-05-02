//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension NotificationCenter {

    /// Posts the notification asynchronously (at ``deadline``) on the specified ``queue``.
    func CC_postAsync(on queue: DispatchQueue, deadline: DispatchTime? = nil, name: Notification.Name, object: Any? = nil) {
        if let deadline {
            queue.asyncAfter(deadline: deadline) { self.post(name: name, object: object) }
        } else {
            queue.async { self.post(name: name, object: object) }
        }
    }
}
