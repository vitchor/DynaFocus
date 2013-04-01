//
//  LikesTableViewCell.m
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "LikesTableViewCell.h"

@implementation LikesTableViewCell

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

-(void) clear {
    
    [m_notification release];
    m_notification = nil;
    
    notificationLabel.text = nil;

    [userImage setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    userImage.tag = 0;
    
}
- (void) refreshWithNotification: (Notification *)notification {
    
    if (!m_notification ||  notification.m_notificationId != m_notification.m_notificationId) {
        
        [self clear];
        
        m_notification = [[Notification alloc] init];
        m_notification.m_message = [[notification.m_message copy] autorelease];
        m_notification.m_notificationId = [[notification.m_notificationId copy] autorelease];
        m_notification.m_userId = [[notification.m_userId copy] autorelease];
        m_notification.m_wasRead = notification.m_wasRead;
        
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        if (m_notification.m_wasRead) {
            backView.backgroundColor = [UIColor whiteColor];
        } else {
            backView.backgroundColor = [UIColor colorWithRed:1 green:0.9 blue:0.78 alpha:1];
        }
        
        
        self.backgroundView = backView;
        
        [notificationLabel setText:m_notification.m_message];
    }
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
