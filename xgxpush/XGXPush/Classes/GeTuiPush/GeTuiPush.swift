//
//  GeTuiPush.swift
//  xgxpush
//
//  Created by  mayong on 2020/11/26.
//  Copyright © 2020年 my. All rights reserved.
//

import GeTuiPackageBridge

public final class XGXGeTuiPushService: NSObject, XGXPushService {
    
    private var callbackPushManagerClosure: ((XGXPUSHNotification, [AnyHashable: Any]) -> Void)?
    public let appId: String
    public let appKey: String
    public let appSecret: String
    public init(appId: String, appKey: String, appSecret: String) {
        self.appId = appId
        self.appKey = appKey
        self.appSecret = appSecret
    }
    
    public func setUpWithLaunchOptions(_ launchOptions: [AnyHashable : Any], production: Bool, channel: String) {
        GeTuiSdk.start(withAppId: appId, appKey: appKey, appSecret: appSecret, delegate: self)
    }
    
    public func setAlias(_ alias: String, sequenceNumber: Int, result: ((Int, String, Int) -> Void)?) {
        GeTuiSdk.bindAlias(alias, andSequenceNum: "\(sequenceNumber)")
    }
    
    public func removeAlias(_ alias: String?, seqNumber: Int) {
        GeTuiSdk.unbindAlias(alias, andSequenceNum: "\(seqNumber)", andIsSelf: true)
    }
    
    @available(iOS 10.0, *)
    public func registerRemoteNotification(_ options: UNAuthorizationOptions) {
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    public func registerRemoteNotification(_ settings: UIUserNotificationSettings) {
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    public func registerDeviceToken(_ deviceToken: Data) {
        GeTuiSdk.registerDeviceTokenData(deviceToken)
    }
    
    public func pushManagerDidHandleRemoteNotitifaction(_ closure: @escaping (XGXPUSHNotification, [AnyHashable : Any]) -> Void) {
        callbackPushManagerClosure = closure
    }
}

extension XGXGeTuiPushService: GeTuiSdkDelegate, UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        GeTuiSdk.handleRemoteNotification(userInfo)
        completionHandler([.sound, .badge, .alert])
    }

    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let request = response.notification.request

        if request.trigger is UNPushNotificationTrigger {
            GeTuiSdk.handleRemoteNotification(userInfo)
            callbackPushManagerClosure?(response.notification, userInfo)
        }
        completionHandler()
    }
}
