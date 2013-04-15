//
//  Notification.h
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_LIKED_FOF 0
#define NOTIFICATION_COMMENTED_FOF 1
#define NOTIFICATION_FOLLOWED_YOU 2
#define NOTIFICATION_COMMENTED_ON_COMMENTED_FOF 3

@interface Notification: NSObject {
    NSString *m_message;
    NSString *m_userId;
    NSDecimalNumber *m_notificationId;
    int m_triggerType;
    int m_triggerId;
    BOOL m_wasRead;
}

+(Notification *) notificationFromJSON: (NSDictionary *)json;

@property (nonatomic, retain) NSString *m_message;
@property (nonatomic, retain) NSString *m_userId;
@property (nonatomic, retain) NSDecimalNumber *m_notificationId;
@property (nonatomic, readwrite) int m_triggerType;
@property (nonatomic, readwrite) int m_triggerId;
@property (nonatomic, readwrite) BOOL m_wasRead;

@end
