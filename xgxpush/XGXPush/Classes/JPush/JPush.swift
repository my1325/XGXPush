//
//  XGXPush-JPush.swift
//  xgxpush
//
//  Created by  mayong on 2020/11/23.
//  Copyright © 2020年 my. All rights reserved.
//
import UserNotifications
import NotificationCenter
import JPUSHPackageBridge

@available(iOS 10.0, *)
extension UNAuthorizationOptions {
    fileprivate var jpushTypes: JPAuthorizationOptions {
        switch self {
        case .alert:
            return .alert
        case .badge:
            return .badge
        case .sound:
            return .sound
        case [.alert, .badge]:
            return [.alert, .badge]
        case [.alert, .sound]:
            return [.alert, .sound]
        case [.badge, .sound]:
            return [.badge, .sound]
        default:
            return [.alert, .badge, .sound]
        }
    }
}

extension UIUserNotificationType {
    fileprivate var jpushTypes: JPAuthorizationOptions {
        switch self {
        case .alert:
            return .alert
        case .badge:
            return .badge
        case .sound:
            return .sound
        case [.alert, .badge]:
            return [.alert, .badge]
        case [.alert, .sound]:
            return [.alert, .sound]
        case [.badge, .sound]:
            return [.badge, .sound]
        default:
            return [.alert, .badge, .sound]
        }
    }
}

public final class XGXJPushService: NSObject, XGXPushService {
    
    private var callbackPushManagerClosure: ((XGXPUSHNotification, [AnyHashable: Any]) -> Void)?
    public let appKey: String
    public init(appKey: String) {
        self.appKey = appKey
    }
    
    public func setUpWithLaunchOptions(_ launchOptions: [AnyHashable : Any], production: Bool, channel: String) {
        JPUSHService.setup(withOption: launchOptions,
                           appKey: appKey,
                           channel: channel,
                           apsForProduction: production)
    }
    
    public func setAlias(_ alias: String, sequenceNumber: Int, result: ((Int, String, Int) -> Void)?) {
        JPUSHService.setAlias(alias, completion: { resultCode, alias, sequenceNumber in
            result?(resultCode, alias ?? "unknown alias", sequenceNumber)
        }, seq: sequenceNumber)
    }
    
    public func removeAlias(_ alias: String?, seqNumber: Int) {
        JPUSHService.deleteAlias(nil, seq: seqNumber)
    }
    
    @available(iOS 10.0, *)
    public func registerRemoteNotification(_ options: UNAuthorizationOptions) {
        let entity = JPUSHRegisterEntity()
        entity.types = Int(options.jpushTypes.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
    }
    
    public func registerRemoteNotification(_ settings: UIUserNotificationSettings) {
        let entity = JPUSHRegisterEntity()
        entity.types = Int(settings.types.jpushTypes.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
    }
    
    public func registerDeviceToken(_ deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    public func pushManagerDidHandleRemoteNotitifaction(_ closure: @escaping (XGXPUSHNotification, [AnyHashable : Any]) -> Void) {
        callbackPushManagerClosure = closure
    }
}

extension XGXJPushService: JPUSHRegisterDelegate {
    
    public func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        
    }
    
    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo;
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue |
                                UNNotificationPresentationOptions.badge.rawValue |
                                UNNotificationPresentationOptions.sound.rawValue))
    }
    
    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        let request = response.notification.request

        if request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
            callbackPushManagerClosure?(response.notification, userInfo)
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        
    }
}

