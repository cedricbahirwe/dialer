//
//  DialerLocalNotificationCenter.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/12/2022.
//

import UserNotifications

final class DialerNotificationCenter {

    private init() {}

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
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Not Authorized", error.localizedDescription)
            throw NotificationError.notAuthorized
        }
    }

    func createNotificaton(_ notification: AppNotification, repeats: Bool = false) async throws {
        guard try await isNotificationAuthorized() else { return }

        let content = UNMutableNotificationContent()
        content.title  = notification.title
        content.body = notification.message
        content.userInfo = notification.info
        content.sound = .default

        if let imageURL = notification.imageUrl,
           let attachement = try? UNNotificationAttachment(identifier: "", url: imageURL, options: .none) {
            content.attachments = [attachement]
        }

        let launchDateTime = notification.scheduledDate
        let dateComponents = Calendar.current.dateComponents([.second], from: launchDateTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)

        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled")
        } catch {
            print("Unable to add notification: ", error.localizedDescription)
            throw NotificationError.notAdded
        }
    }

    func removeDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func scheduleMorningReminder() {
        let nextDay9AM = getNextDate()
        let dailyNotification: DialerLocalNotification
        dailyNotification = .init(id: UUID(),
                                  title: "Good morning!, Have a Great Day",
                                  message: "Buy airtime, transfer money and do more with Dialer!",
                                  info: [:],
                                  scheduledDate: nextDay9AM)
        Task {
            try? await createNotificaton(dailyNotification, repeats: true)
        }
    }

    private func getNextDate(from date: Date = .now) -> Date {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let todayDay9AM = Calendar.current.date(from: components) ?? .now
        let tomorrowDay9AM = Calendar.current.date(byAdding: .day, value: 1, to: todayDay9AM)


        return tomorrowDay9AM ?? .now
    }
}

extension DialerNotificationCenter {
    enum NotificationError: Error {
        case notAuthorized
        case notAdded
        case unknown(String)

        var explanation: String {
            switch self {
            case .notAuthorized:
                return "Notification not authorized: \(localizedDescription)"
            case .notAdded:
                return "Unable to add notification: \(localizedDescription)"
            case .unknown(let message):
                return message
            }
        }
    }
}
