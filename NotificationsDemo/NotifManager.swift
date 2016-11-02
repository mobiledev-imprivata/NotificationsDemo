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
    
}
