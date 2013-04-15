//
//  Settings.h
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

#define dyfocus_url @"http://dyfoc.us"
//#define dyfocus_url @"http://192.168.0.104:8000"
//#define dyfocus_url @"http://192.168.0.112:8000"
//#define dyfocus_url @"http://192.168.100.140:8000"
//#define dyfocus_url @"http://192.168.0.109:8000"

#define app_fb_id @"417476174956036"

#define refresh_user_url @"/uploader/json_user_fof/"
#define refresh_featured_url @"/uploader/json_featured_fof/"
#define refresh_feed_url @"/uploader/json_feed/"

@interface Settings : NSObject

@end
