//
//  NotifManager.swift
//  NotificationsDemo
//
//  Created by Jay Tucker on 11/2/16.
//  Copyright © 2016 Imprivata. All rights reserved.
//

import UIKit
import UserNotifications

// needs to inherit from NSObject so it can conform to UNUserNotificationCenterDelegate
final class NotifManager: NSObject {
    
    fileprivate let notificationsDemoCategoryName = "notificationsDemo"
    
    enum Identifier: String {
        // for authentication challenge
        case Accept = "com.imprivata.Approve"
        case Reject = "com.imprivata.Deny"
    }
    
    // singleton
    static let sharedInstance = NotifManager()
    
    private var nLocalNotification = 0
    
    fileprivate var uiBackgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    private override init() {}
    
    func requestAuthorization() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                if granted {
                    log("permission granted")
                    
                    let acceptAction = UNNotificationAction(identifier: Identifier.Accept.rawValue, title: Identifier.Accept.rawValue.replacingOccurrences(of: "com.imprivata.", with: ""), options: [])
                    let rejectAction = UNNotificationAction(identifier: Identifier.Reject.rawValue, title: Identifier.Reject.rawValue.replacingOccurrences(of: "com.imprivata.", with: ""), options: [])
                    let category = UNNotificationCategory(identifier: self.notificationsDemoCategoryName, actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [])
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                    
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    log("permission not granted")
                }
                if let error = error {
                    log(error.localizedDescription)
                }
            }
        } else {
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            
            let acceptAction = createUserNotificationAction(Identifier.Accept)
            let rejectAction = createUserNotificationAction(Identifier.Reject)
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = notificationsDemoCategoryName
            category.setActions([acceptAction, rejectAction], for: .default)
            category.setActions([acceptAction, rejectAction], for: .minimal)
            
            let settings = UIUserNotificationSettings(types: types, categories: [category])
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func scheduleLocalNotification() {
        nLocalNotification += 1
        log("scheduleLocalNotification \(nLocalNotification)")

        let body = "Here's local challenge \(nLocalNotification)!"
        let delay: TimeInterval = 5
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = notificationsDemoCategoryName
            content.title = "Hello, iOS 10!"
            content.body = body
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            
            let identifier = "localNotification_\(nLocalNotification)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                error in
                if let error = error {
                    log("error scheduling local notification \(error.localizedDescription)")
                }
            }
        } else {
            let notification = UILocalNotification()
            notification.category = notificationsDemoCategoryName
            notification.alertTitle = "Hello, iOS 9!"
            notification.alertBody = body
            notification.fireDate = Date(timeIntervalSinceNow: delay)
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    func removePendingNotifications() {
        log("removePendingNotifications")
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests {
                requests in
                log("\(requests.count) pending request(s)")
                for request in requests {
                    log("  \(request.identifier)")
                }
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
    func removeDeliveredNotifications() {
        log("removeDeliveredNotifications")
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getDeliveredNotifications {
                notifications in
                log("\(notifications.count) delivered notifications(s)")
                for notification in notifications {
                    log("  \(notification.request.identifier)")
                }
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            }
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
}

@available(iOS 10.0, *)
extension NotifManager: UNUserNotificationCenterDelegate {
    
    // called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log("response received for \(response.actionIdentifier)")
        if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" {
            let body = response.notification.request.content.body
            NotifManager.sharedInstance.showForegroundNotification(version: "10", body: body)
        }
        completionHandler()
    }
    
}

@available(iOS, deprecated: 10.0)
extension NotifManager {
    
    fileprivate func createUserNotificationAction(_ identifier: Identifier) -> UIMutableUserNotificationAction {
        let action = UIMutableUserNotificationAction()
        action.identifier = identifier.rawValue
        action.title = identifier.rawValue.replacingOccurrences(of: "com.imprivata.", with: "")
        action.activationMode = .background
        action.isAuthenticationRequired = false
        action.isDestructive = false
        return action
    }
    
    func showForegroundNotification(version: String, body: String) {
        log("showForegroundNotification")
        
        let denyAction = UIAlertAction(title: "Deny", style: .default) {
            _ in
            log("denied")
        }
        
        let approveAction = UIAlertAction(title: "Approve", style: .default) {
            _ in
            log("approved")
        }
        
        let title = "Hello, iOS \(version)!"

        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(denyAction)
        alertController.addAction(approveAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}

// used for debugging
extension NotifManager {
    
    func dumpNotificationUserInfo(_ userInfo: [AnyHashable: Any]) {
        log("dumpNotificationUserInfo")
        dumpDictionary(userInfo as! [String:AnyObject], level: 0)
        
    }
    
    private func dumpDictionary(_ dict: [String:AnyObject], level: Int) {
        let indent = String(repeating: " ", count: 2 * level)
        for key in dict.keys {
            let val = dict[key]
            if val is String {
                log("\(indent)\(key) => \(val!) (string)")
            } else if val is Int {
                log("\(indent)\(key) => \(val!) (number)")
            } else if val is [String:AnyObject] {
                log("\(indent)\(key) => (dict)")
                dumpDictionary(val as! [String:AnyObject], level: level + 1)
            } else {
                log("\(indent)\(key) => (unknown)")
            }
        }
    }
    
}
