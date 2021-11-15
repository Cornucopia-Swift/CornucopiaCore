//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension NotificationCenter {

    func CC_postAsync(on queue: DispatchQueue, name: Notification.Name, object: Any? = nil) {
        queue.async { self.post(name: name, object: object) }
    }
}
