//
//  NotificationTableViewCell.m
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "NotificationTableViewCell.h"


@implementation NotificationTableViewCell

@synthesize userImage, notificationLabel, m_notification;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) clear {
    
    self.notificationLabel.text = nil;

    [self.userImage setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    self.userImage.tag = 0;
    
}

-(void) loadImage {
    if (self.userImage.tag != 420) {
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        [imageLoader loadPictureWithFaceId:self.m_notification.m_userFacebookId andImageView:self.userImage andIsSmall:YES];
    }
    
    
}

- (void) refreshWithNotification: (Notification *)notification {
    
    if (!self.m_notification ||  notification.m_notificationId != self.m_notification.m_notificationId) {
        
        [self clear];
        
        self.m_notification = notification;
        
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        if (self.m_notification.m_wasRead) {
            backView.backgroundColor = [UIColor whiteColor];
        } else {
            backView.backgroundColor = [UIColor colorWithRed:1 green:0.9 blue:0.78 alpha:1];
        }
        
        
        self.backgroundView = backView;
        
        [self.notificationLabel setText:self.m_notification.m_message];
    }
}

-(void)dealloc
{
    [userImage release];
    [notificationLabel release];
    [m_notification release];
    
    [super dealloc];
}

@end
