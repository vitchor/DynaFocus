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
    m_like.m_userFacebookId = like.m_userFacebookId;
    m_like.m_userId = like.m_userId;
    m_like.m_uid = like.m_uid;
    
    if([like.m_userName isEqualToString:@"You"]){
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        m_like.m_userName = delegate.myself.name;
        self.userNameLabel.text = delegate.myself.name;
    }else{
        m_like.m_userName = like.m_userName;
        self.userNameLabel.text = like.m_userName;
    }

    [self loadImage];
//    TODO COPY THE REST
}

-(void) loadImage{
    if (userImage.tag != 420) {
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        [imageLoader loadPictureWithFaceId:m_like.m_userFacebookId andImageView:userImage andIsSmall:YES];
    }
}

@end
