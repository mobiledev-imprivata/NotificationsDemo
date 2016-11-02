//
//  NotifManager.swift
//  NotificationsDemo
//
//  Created by Jay Tucker on 11/2/16.
//  Copyright © 2016 Imprivata. All rights reserved.
//

import UIKit
import UserNotifications

final class NotifManager {
    
    enum Identifier: String {
        // for authentication challenge
        case Accept = "com.imprivata.Approve"
        case Reject = "com.imprivata.Deny"
    }
    
    // singleton
    static let sharedInstance = NotifManager()
    
    private var nLocalNotification = 0
    
    private var uiBackgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    private init() {}
    
    func requestAuthorization() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                if granted {
                    log("permission granted")
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
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func scheduleLocalNotification() {
        if #available(iOS 10.0, *) {
            let identifier = "localNotification_\(nLocalNotification)"
            log("scheduling \(identifier)")
            
            nLocalNotification += 1
            
            let title = "Here's a challenge!"
            let body = "Whatcha wanna do?"
            
            let content = UNMutableNotificationContent()
            // content.categoryIdentifier = newCuddlePixCategoryName
            content.title = title
            content.body = body
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                error in
                if let error = error {
                    log("error scheduling local notification \(error.localizedDescription)")
                }
            }
        } else {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(5000)
            beginBackgroundTask()
            DispatchQueue.global().asyncAfter(deadline: deadline) {
                self.scheduleDelayedLocalNotification()
            }
        }
    }
    
    private func scheduleDelayedLocalNotification() {
        log("scheduleDelayedLocalNotification")
        
        let title = "Here's a challenge!"
        let body = "Whatcha wanna do?"
        
        if UIApplication.shared.applicationState == .active {
            // TODO: do something when app is in foreground
            log("show something in the foreground")
            // showNotification(title, message: message)
        } else {
            let notification = UILocalNotification()
            // notification.category = ...
            notification.alertTitle = title
            notification.alertBody = body
            notification.fireDate = Date()
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        endBackgroundTask()
    }
    
    private func beginBackgroundTask() {
        uiBackgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask (expirationHandler: {
            log("background task expired")
            self.endBackgroundTask()
        })
        log("beginBackgroundTask \(uiBackgroundTaskIdentifier)")
    }
    
    private func endBackgroundTask() {
        log("endBackgroundTask \(uiBackgroundTaskIdentifier)")
        UIApplication.shared.endBackgroundTask(uiBackgroundTaskIdentifier)
        uiBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    }
    
}
