//
//  DialerLocalNotificationCenter.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/12/2022.
//

import UserNotifications

final class DialerNotificationCenter: NSObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private static var _shared: DialerNotificationCenter?

    static let shared: DialerNotificationCenter = {
        if let existingInstance = _shared {
            _shared = existingInstance
        } else {
            _shared = DialerNotificationCenter()
        }
        return _shared!
    }()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func scheduleMorningNotification() {
        
        guard !DialerStorage.shared.isDailyNotificationEnabled() else { return }
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let dailyNotification = DialerLocalNotification(
            id: UUID(),
            title: "Good morning!, Have a Great Day☀️",
            message: "Buy airtime, Transfer money and Do more with Dialer!",
            info: [:],
            scheduledDate: dateComponents
        )
        Task {
            do {
                try await createNotification(dailyNotification, repeats: true)
                DialerStorage.shared.setDailyNotificationStatus(to: true)
            } catch {
                Log.debug("Issue with notification", error.localizedDescription)
            }
        }
    }
}

// MARK: - Helper Methods
private extension DialerNotificationCenter {
    func isNotificationAuthorized() async throws -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Not Authorized", error.localizedDescription)
            throw NotificationError.notAuthorized
        }
    }
    
    func createNotification(_ notification: AppNotification, repeats: Bool) async throws {
        guard try await isNotificationAuthorized() else { return }

        let content = UNMutableNotificationContent()
        content.title  = notification.title
        content.body = notification.message
        content.userInfo = notification.info
        content.sound = UNNotificationSound.default

        if let imageURL = notification.imageUrl,
           let attachement = try? UNNotificationAttachment(identifier: "", url: imageURL, options: .none) {
            content.attachments = [attachement]
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: notification.scheduledDate, repeats: repeats)

        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            Log.debug("Unable to add notification: ", error.localizedDescription)
            throw NotificationError.notAdded
        }
    }
}

extension DialerNotificationCenter {
    func deleteNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        DialerStorage.shared.setDailyNotificationStatus(to: false)
    }
    
    ///Prints to console schduled notifications
    func printNotifications() {
        Task {
            let pendingNotifs = await notificationCenter.pendingNotificationRequests()
            
            Log.debug("Pending Notifications Count: ", pendingNotifs.count)
            
        }
    }
}

//MARK: UNUserNotificationCenterDelegate
extension DialerNotificationCenter: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
    }
}

extension DialerNotificationCenter {
    enum NotificationError: Error {
        case notAuthorized
        case notAdded
    }
}
