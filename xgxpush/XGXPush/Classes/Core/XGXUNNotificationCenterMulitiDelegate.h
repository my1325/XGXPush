//
//  XGXUNNotificationCenterMulitiDelegate.h
//  XGXPush
//
//  Created by my on 2020/11/26.
//

#import <Foundation/Foundation.h>
@import UserNotifications;

@interface XGXUNNotificationCenterMulitiDelegate: NSObject<UNUserNotificationCenterDelegate>

- (void)addDelegate: (id<UNUserNotificationCenterDelegate>)delegate API_AVAILABLE(ios(10.0));
@end
