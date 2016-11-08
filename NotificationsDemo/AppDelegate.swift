//
//  AppDelegate.swift
//  NotificationsDemo
//
//  Created by Jay Tucker on 11/2/16.
//  Copyright © 2016 Imprivata. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // delegate must be assigned no later than here
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = NotifManager.sharedInstance
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        log("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        log("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        log("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        log("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        log("didRegisterForRemoteNotificationsWithDeviceToken \(deviceTokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)")
    }

}

@available(iOS, deprecated: 10.0)
extension AppDelegate {

    // local notifications
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log("application didReceive notification")
        let body = notification.alertBody!
        NotifManager.sharedInstance.showForegroundNotification(version: "9", body: body)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        log("application handleActionWithIdentifier \(identifier)")
        completionHandler()
    }
    
    // remote notifications

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        log("application didReceiveRemoteNotification")
        NotifManager.sharedInstance.dumpNotificationUserInfo(userInfo)
        // TODO: add body
        NotifManager.sharedInstance.showForegroundNotification(version: "9", body: "blah")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        log("application handleActionWithIdentifier \(identifier) forRemoteNotification")
        NotifManager.sharedInstance.dumpNotificationUserInfo(userInfo)
        completionHandler()
    }
    
}
