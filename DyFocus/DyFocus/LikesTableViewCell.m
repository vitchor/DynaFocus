//
//  LikesTableViewCell.m
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "LikesTableViewCell.h"


@implementation LikesTableViewCell

@synthesize userImage, userNameLabel, m_like;

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
    
    self.userNameLabel.text = nil;

    [self.userImage setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    self.userImage.tag = 0;
}

-(void) loadImage{
    if (self.userImage.tag != 420) {
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        [imageLoader loadPictureWithFaceId:self.m_like.m_userFacebookId andImageView:self.userImage andIsSmall:YES];
    }
}

- (void) refreshWithLike:(Like *)like{
    
    [self clear];
    
    self.m_like = like;
    
    if([like.m_userName isEqualToString:@"You"]){
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        self.m_like.m_userName = delegate.myself.name;
        self.userNameLabel.text = delegate.myself.name;
    }else{
        self.userNameLabel.text = like.m_userName;
    }

    [self loadImage];
//    TODO COPY THE REST
}

-(void)dealloc
{
    [userImage release];
    [userNameLabel release];
    [m_like release];
    
    [super dealloc];
}

@end
