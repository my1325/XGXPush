//
//  AppDelegate.swift
//  XGXPush
//
//  Created by my on 11/23/2020.
//  Copyright (c) 2020 my. All rights reserved.
//

import UIKit
import XGXPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        XGXPush.shared.addObserver(self)
        
        let isProduction: Bool
        #if DEBUG
        isProduction = false
        #else
        isProduction = true
        #endif
        
        let jpushService = XGXJPushService(appKey: "")
//        let GeTuiService = XGXGeTuiPushService(appId: "", appKey: "", appSecret: "")
        
        XGXPush.shared.setupWithLaunchOptions(launchOptions ?? [:], service: jpushService, production: isProduction, channel: "APPStore")
        
        if #available(iOS 10, *) {
            XGXPush.shared.registerRemoteNotificationForOptions([.alert, .badge, .sound])
        } else {
            XGXPush.shared.registerRemoteNotificationForSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound] , categories: nil))
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        XGXPush.shared.applicationDidReceiveRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        XGXPush.shared.applicationDidRegisterRemoteNotificationDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        XGXPush.shared.applicationDidFailedRegisterRemoteNotification(error)
    }
}

extension AppDelegate: XGXPushObserver {
    func notificationService(_ service: XGXPushService?, didReceiveRemoteNotification notification: XGXPUSHNotification, userInfo: [AnyHashable : Any]) {
        /// TODO: handle user info code
    }
}

