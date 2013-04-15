//
//  Notification.m
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@synthesize m_message, m_userId, m_notificationId, m_wasRead, m_triggerId, m_triggerType;

+(Notification *)notificationFromJSON: (NSDictionary *)json {
    Notification *notification = [[Notification alloc] autorelease];
    
    notification.m_message = [json objectForKey:@"message"];
    notification.m_userId = [json objectForKey:@"user_facebook_id"];
    notification.m_notificationId = (NSDecimalNumber *)[json objectForKey:@"notification_id"];
    notification.m_wasRead = [[json objectForKey:@"was_read"] intValue] ==  1;
    notification.m_triggerId = [[json objectForKey:@"trigger_id"] intValue];
    notification.m_triggerType = [[json objectForKey:@"trigger_type"] intValue];
    
    return notification;
}

- (void)dealloc {
    [m_message release];
    [m_userId release];
    [m_notificationId release];
	[super dealloc];
}


@end