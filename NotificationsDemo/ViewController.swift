//
//  ViewController.swift
//  NotificationsDemo
//
//  Created by Jay Tucker on 11/2/16.
//  Copyright © 2016 Imprivata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotifManager.sharedInstance.requestAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func scheduleLocalNotification(_ sender: Any) {
        NotifManager.sharedInstance.scheduleLocalNotification()
    }

    @IBAction func removePendingNotifications(_ sender: Any) {
        NotifManager.sharedInstance.removePendingNotifications()
    }
    
    @IBAction func removeDeliveredNotifications(_ sender: Any) {
        NotifManager.sharedInstance.removeDeliveredNotifications()
    }
    
}

