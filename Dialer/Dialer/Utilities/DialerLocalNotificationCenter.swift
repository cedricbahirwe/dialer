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

    func createNotification(_ notification: AppNotification, repeats: Bool = false) async throws {
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

        let trigger = UNCalendarNotificationTrigger(dateMatching: notification.scheduledDate, repeats: repeats)

        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled")
        } catch {
            print("Unable to add notification: ", error.localizedDescription)
            throw NotificationError.notAdded
        }
    }

    func scheduleMorningReminder() {
        let nextDay9AMComponents = getNextDateComponents()
        let dailyNotification: DialerLocalNotification
        dailyNotification = .init(id: UUID(),
                                  title: "Good morning!, Have a Great Day",
                                  message: "Buy airtime, transfer money and do more with Dialer!",
                                  info: [:],
                                  scheduledDate: nextDay9AMComponents)
        Task {
            try? await createNotification(dailyNotification, repeats: true)
        }
    }
}

private extension DialerNotificationCenter {
    func getNextDateComponents() -> DateComponents {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let todayDay9AM = Calendar.current.date(from: components) ?? .now

        let tomorrowDay9AM = Calendar.current.date(byAdding: .day, value: 1, to: todayDay9AM)

        let dateComponents = getComponents([.hour, .minute], from: tomorrowDay9AM ?? .now)

        return dateComponents
    }

    func getComponents(_ components: Set<Calendar.Component>, from date: Date) -> DateComponents {
        return Calendar.current.dateComponents(components, from: date)
    }
}

extension DialerNotificationCenter {
    enum NotificationError: Error {
        case notAuthorized
        case notAdded
    }
}