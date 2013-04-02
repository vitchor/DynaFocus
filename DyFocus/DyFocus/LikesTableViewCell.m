//
//  LikesTableViewCell.m
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "LikesTableViewCell.h"
#import "UIImageLoaderDyfocus.h"
#import "AppDelegate.h"

@implementation LikesTableViewCell

@synthesize userImage, userNameLabel;

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
    
    [m_like release];
    m_like = nil;
    
    userNameLabel.text = nil;

    [userImage setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    userImage.tag = 0;
}

- (void) refreshWithLike:(Like *)like{
    [self clear];

    m_like = [[Like alloc] init];
    m_like.m_userId = [like.m_userId copy];
    
    if([like.m_userName isEqualToString:@"You"]){
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        m_like.m_userName = [delegate.myself.name copy];
        self.userNameLabel.text = delegate.myself.name;
    }else{
        m_like.m_userName = [like.m_userName copy];
        self.userNameLabel.text = like.m_userName;
    }

    [self loadImage];
//    TODO COPY THE REST
}

-(void) loadImage{
    if (userImage.tag != 420) {
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",m_like.m_userId];
        
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
