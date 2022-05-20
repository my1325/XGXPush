//
//  XGXPush.swift
//  xgxpush
//
//  Created by  mayong on 2020/11/23.
//  Copyright © 2020年 my. All rights reserved.
//
import Foundation
import UserNotifications
import NotificationCenter

public protocol XGXPUSHNotification {}

@available(iOS 10.0, *)
extension UNNotification: XGXPUSHNotification {}
extension Notification: XGXPUSHNotification {}

public protocol XGXPushService {
    func setUpWithLaunchOptions(_ launchOptions: [AnyHashable: Any], production: Bool, channel: String)
    
    func setAlias(_ alias: String, sequenceNumber: Int, result: ((Int, String, Int) -> Void)?)
    
    func removeAlias(_ alias: String?, seqNumber: Int)
    
    @available(iOS 10.0, *)
    func registerRemoteNotification(_ options: UNAuthorizationOptions)
    
    func registerRemoteNotification(_ settings: UIUserNotificationSettings)
    
    func registerDeviceToken(_ deviceToken: Data)
    
    func pushManagerDidHandleRemoteNotitifaction(_ closure: @escaping(_ notification: XGXPUSHNotification, _ userInfo: [AnyHashable: Any]) -> Void)
}

public protocol XGXPushObserver {
    func notificationService(_ service: XGXPushService?, didReceiveRemoteNotification notification: XGXPUSHNotification, userInfo: [AnyHashable: Any])
    
    func notificationService(_ service: XGXPushService?, didFailToRegisterRemoteNotification error: Error)
    
    func notificationService(_ service: XGXPushService?, didSuccessRegisterRemoteNotification deviceToken: Data)
    
    func notificationService(_ service: XGXPushService?, didRequestNotificationAuthorization result: Bool)
}

extension XGXPushObserver {
    public func notificationService(_ service: XGXPushService?, didFailToRegisterRemoteNotification error: Error) {}
    
    public func notificationService(_ service: XGXPushService?, didSuccessRegisterRemoteNotification deviceToken: Data) {}
    
    public func notificationService(_ service: XGXPushService?, didRequestNotificationAuthorization result: Bool) {}
}

public final class XGXPush {
    public static let shared = XGXPush()
    
    private init() {}
    
    public private(set) var pushService: XGXPushService?
    
    public private(set) var observerList = NSPointerArray.weakObjects()
    
    private let lock = DispatchSemaphore(value: 1)
    
    public func setupWithLaunchOptions(_ launchOptions: [AnyHashable: Any], service: XGXPushService, production: Bool = true, channel: String = "APPStore") {
        pushService = service
        pushService?.pushManagerDidHandleRemoteNotitifaction({ [weak self] notification, userInfo in
            self?.handleUserInfo(userInfo, from: notification)
        })
        service.setUpWithLaunchOptions(launchOptions, production: production, channel: channel)
    }
    
    public func requestNotificationAuthorization() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { [weak self] isSuccess, _ in
                self?.compactPointerArray()
                self?.forEachObserverList { observer in
                    observer.notificationService(self?.pushService, didRequestNotificationAuthorization: isSuccess)
                }
            })
        } else {
            DispatchQueue.main.async {
                let result = UIApplication.shared.currentUserNotificationSettings == nil ||
                    UIApplication.shared.currentUserNotificationSettings?.types == UIUserNotificationType(rawValue: 0)
                self.compactPointerArray()
                self.forEachObserverList { observer in
                    observer.notificationService(self.pushService, didRequestNotificationAuthorization: result)
                }
            }
        }
    }
    
    @available(iOS 10.0, *)
    public func registerRemoteNotificationForOptions(_ options: UNAuthorizationOptions) {
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { [weak self] isSuccess, _ in
            self?.compactPointerArray()
            self?.forEachObserverList { observer in
                observer.notificationService(self?.pushService, didRequestNotificationAuthorization: isSuccess)
            }
        })
        pushService?.registerRemoteNotification(options)
    }
    
    public func registerRemoteNotificationForSettings(_ setttings: UIUserNotificationSettings) {
        pushService?.registerRemoteNotification(setttings)
    }
    
    public func applicationDidRegisterRemoteNotificationDeviceToken(_ deviceToken: Data) {
        pushService?.registerDeviceToken(deviceToken)
        forEachObserverList { observer in
            observer.notificationService(self.pushService, didSuccessRegisterRemoteNotification: deviceToken)
        }
    }
    
    public func applicationDidFailedRegisterRemoteNotification(_ error: Error) {
        forEachObserverList { observer in
            observer.notificationService(self.pushService, didFailToRegisterRemoteNotification: error)
        }
    }
    
    @available(iOS, introduced: 7.0, deprecated: 10.0)
    public func applicationDidReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        let notification = Notification(name: Notification.Name("com.xgx.push.remote.notification"))
        forEachObserverList { observer in
            observer.notificationService(self.pushService, didReceiveRemoteNotification: notification, userInfo: userInfo)
        }
    }
    
    public func addObserver<O: XGXPushObserver & NSObject>(_ observer: O) {
        compactPointerArray()
        
        /// 加入新的指针
        let observerPointer = Unmanaged.passUnretained(observer).toOpaque()
        lockObserverList { list in
            list.addPointer(observerPointer)
        }
    }
    
    /// 清除废弃的空指针
    private func compactPointerArray() {
        observerList.addPointer(nil)
        observerList.compact()
    }
    
// MARK: - private
    private func handleUserInfo(_ userInfo: [AnyHashable: Any], from notification: XGXPUSHNotification) {
        forEachObserverList { observer in
            observer.notificationService(self.pushService, didReceiveRemoteNotification: notification, userInfo: userInfo)
        }
    }
    
    /// 对observerList加锁
    private func lockObserverList(_ closure: @escaping (NSPointerArray) -> Void) {
        lock.wait()
        defer { lock.signal() }
        closure(observerList)
    }
    
    /// 对observerList加一个循环
    private func forEachObserverList(_ closure: @escaping (XGXPushObserver) -> Void) {
        lockObserverList { list in
            for index in 0 ..< list.count {
                guard let pointer = list.pointer(at: index) else { continue }
                let object = Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
                if let observer = object as? XGXPushObserver {
                    closure(observer)
                }
            }
        }
    }
}
