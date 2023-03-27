//
//  DialerLocalNotificationCenter.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/12/2022.
//

import UserNotifications

final class DialerNotificationCenter: NSObject {
    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    

    private static var _shared: DialerNotificationCenter?

    static let shared: DialerNotificationCenter = {
        if let existingInstance = _shared {
            _shared = existingInstance
        } else {
            _shared = DialerNotificationCenter()
        }
        return _shared!
    }()

    private func isNotificationAuthorized() async throws -> Bool {
        debugPrint(#function)
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Not Authorized", error.localizedDescription)
            throw NotificationError.notAuthorized
        }
    }

    func createNotification(_ notification: AppNotification, repeats: Bool = false) async throws {
        debugPrint(#function)
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
            debugPrint("Unable to add notification: ", error.localizedDescription)
            throw NotificationError.notAdded
        }
    }

    func scheduleMorningReminder() {
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let dailyNotification: DialerLocalNotification
        dailyNotification = .init(id: UUID(),
                                  title: "Good morning!, Have a Great Day☀️",
                                  message: "Buy airtime, Transfer money and Do more with Dialer!",
                                  info: [:],
                                  scheduledDate: dateComponents)
        Task {
            try? await createNotification(dailyNotification, repeats: true)
        }
    }
}

extension DialerNotificationCenter {
    func deleteNotifications() {
        debugPrint(#function)
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    ///Prints to console schduled notifications
    func printNotifications() {
        debugPrint(#function)
        Task {
            let pendingNotifs = await notificationCenter.pendingNotificationRequests()
            
            debugPrint("We have", pendingNotifs.count)
            
        }
    }
}

extension DialerNotificationCenter: UNUserNotificationCenterDelegate {
    //MARK: UNUserNotificationCenterDelegate
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
