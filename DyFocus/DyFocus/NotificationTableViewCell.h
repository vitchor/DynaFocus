//
//  NotificationTableViewCell.h
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "UIImageLoaderDyfocus.h"

@interface NotificationTableViewCell : UITableViewCell {
    
    Notification *m_notification;
}

@property (nonatomic,retain) IBOutlet UIImageView *userImage;
@property (nonatomic,retain) IBOutlet UILabel *notificationLabel;

- (void) loadImage;
- (void) refreshWithNotification:(Notification *)notification;

@end
