//
//  NotificationTableViewCell.m
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

@synthesize userImage, notificationLabel;

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

- (void) refreshWithNotification: (Notification *)notification {
    
    if (m_notification) {
        [m_notification release];
        m_notification = nil;
    }
    m_notification = [[Notification alloc] init];
    m_notification.m_message = [[notification.m_message copy] autorelease];
    m_notification.m_notificationId = [[notification.m_notificationId copy] autorelease];
    m_notification.m_userId = [[notification.m_userId copy] autorelease];
    m_notification.m_wasRead = notification.m_wasRead;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (m_notification.m_wasRead) {
        backView.backgroundColor = [UIColor whiteColor];
    } else {
        backView.backgroundColor = [UIColor colorWithRed:1 green:0.9 blue:0.78 alpha:1];
    }
    
    
    self.backgroundView = backView;
    
    [notificationLabel setText:m_notification.m_message];
}

-(void) loadImage {
    
    if (userImage.tag != 420) {
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",m_notification.m_userId];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:profilePictureUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       UIImage *image = [UIImage imageWithData:data];
                                       if(image) {
                                           [userImage setImage:image];
                                           userImage.tag = 420;
                                       }
                                   }
                               }];
    }
    

}

@end
