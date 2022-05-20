//
//  XGXUNNotificationCenterMulitiDelegate.m
//  XGXPush
//
//  Created by my on 2020/11/26.
//

#import "XGXUNNotificationCenterMulitiDelegate.h"
#import <objc/runtime.h>
#import <objc/objc.h>

@interface UNUserNotificationCenter (XGXNotificationMulitiDelegate)

@end

@implementation UNUserNotificationCenter  (XGXNotificationMulitiDelegate)

+ (void)initialize {
    Method originMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
    Method destMethod = class_getInstanceMethod([self class], @selector(xgx_setDelegate:));
    method_exchangeImplementations(originMethod, destMethod);
}

- (void)xgx_setDelegate: (id<UNUserNotificationCenterDelegate>)delegate {
    XGXUNNotificationCenterMulitiDelegate * _delegate = [self getMuiltiDelegate];
    if (!self.delegate) {
        [self xgx_setDelegate:_delegate];
    }
    
    [_delegate addDelegate:delegate];
}

- (XGXUNNotificationCenterMulitiDelegate *)getMuiltiDelegate {
    XGXUNNotificationCenterMulitiDelegate * retDelegate = objc_getAssociatedObject(self, _cmd);
    if (!retDelegate) {
        retDelegate = [[XGXUNNotificationCenterMulitiDelegate alloc] init];
        objc_setAssociatedObject(self, _cmd, retDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return retDelegate;
}
@end

@implementation XGXUNNotificationCenterMulitiDelegate {
    NSPointerArray * _pointerArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _pointerArray = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)addDelegate:(id<UNUserNotificationCenterDelegate>)delegate {
    [self _compactPointerArray];
    [_pointerArray addPointer:(__bridge void * _Nullable)(delegate)];
}

- (void)_compactPointerArray {
    [_pointerArray addPointer:nil];
    [_pointerArray compact];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)){
    [self _compactPointerArray];
    for (NSInteger index = 0; index < _pointerArray.count; index ++) {
        id<UNUserNotificationCenterDelegate> delegate = [_pointerArray pointerAtIndex:index];
        if (delegate && [delegate respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
            [delegate userNotificationCenter:center
                     willPresentNotification:notification
                       withCompletionHandler:completionHandler];
        }
    }
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    [self _compactPointerArray];
    for (NSInteger index = 0; index < _pointerArray.count; index ++) {
        id<UNUserNotificationCenterDelegate> delegate = [_pointerArray pointerAtIndex:index];
        if (delegate && [delegate respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
            [delegate userNotificationCenter:center
              didReceiveNotificationResponse:response
                       withCompletionHandler:completionHandler];
        }
    }
}

// The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification  API_AVAILABLE(ios(12.0)){
    [self _compactPointerArray];
    for (NSInteger index = 0; index < _pointerArray.count; index ++) {
        id<UNUserNotificationCenterDelegate> delegate = [_pointerArray pointerAtIndex:index];
        if (delegate && [delegate respondsToSelector:@selector(userNotificationCenter:openSettingsForNotification:)]) {
            [delegate userNotificationCenter:center openSettingsForNotification:notification];
        }
    }
}
@end
