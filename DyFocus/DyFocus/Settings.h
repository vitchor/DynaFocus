//
//  Settings.h
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define dyfocus_url @"http://dyfoc.us"
//#define dyfocus_url @"http://192.168.0.102:8000"
//#define dyfocus_url @"http://192.168.0.112:8000"
//#define dyfocus_url @"http://192.168.100.140:8000"
//#define dyfocus_url @"http://172.20.10.2:8000"
//#define dyfocus_url @"http://192.168.1.5:8000"

#define app_fb_id @"417476174956036"

#define refresh_user_url @"/uploader/json_user_id_fof/"
#define refresh_featured_url @"/uploader/user_json_featured_fof/"
#define refresh_feed_url @"/uploader/user_json_feed/"
#define refresh_trending_url @"/uploader/trending/"

#define FREE_AD_VERSION true
//#define FREE_AD_VERSION false

@interface Settings : NSObject

@end
