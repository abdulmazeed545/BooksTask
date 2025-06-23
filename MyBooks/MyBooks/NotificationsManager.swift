//
//  NotificationsManager.swift
//  MyBooks
//
//  Created by Mazeed on 23/06/25.
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    func checkAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    completion(true)
                case .denied:
                    print("Notifications denied")
                    completion(false)
                case .notDetermined:
                    self.requestAuthorization(completion: completion)
                default:
                    completion(false)
                }
            }
        }
    }
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                print("Notification permission granted: \(granted)")
                completion(granted)
            }
        }
    }
    
    
    /*func scheduleDeletionNotification(for productName: String) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Product Deleted"
            content.body = "\(productName) was removed"
            content.sound = .default
            content.badge = 1
            
            // Increased trigger time to 5 seconds for better visibility
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "del_notif_\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Notification error: \(error.localizedDescription)")
                } else {
                    print("Successfully scheduled notification for: \(productName)")
                    
                    // Immediate visual feedback
                    DispatchQueue.main.async {
                        // Add haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }
            }
        }
    }*/
    
    func scheduleDeletionNotification(for productName: String) {
            // First check if notifications are enabled in settings
            guard SettingsManager.shared.notificationsEnabled else {
                print("Notifications disabled in settings - not sending")
                return
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else {
                    print("Notifications not authorized by user")
                    return
                }
                
                let content = UNMutableNotificationContent()
                content.title = "Product Deleted"
                content.body = "\(productName) was removed from your list"
                content.sound = .default
                // Add this to ensure your app icon appears
                content.badge = 1  // Optional badge count
                content.userInfo = ["appIcon": "book"]  // Optional custom data
                
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled for \(productName)")
                    }
                }
            }
        }
}
