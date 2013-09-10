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
    
}

@property (nonatomic,retain) IBOutlet UIImageView *userImage;
@property (nonatomic,retain) IBOutlet UILabel *notificationLabel;

@property (nonatomic,retain) Notification *m_notification;

- (void) loadImage;
- (void) refreshWithNotification:(Notification *)notification;

@end
