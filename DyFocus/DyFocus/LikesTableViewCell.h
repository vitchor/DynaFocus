//
//  LikesTableViewCell.h
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "UIImageLoaderDyfocus.h"

@interface LikesTableViewCell : UITableViewCell {

    Like *m_like;
}

@property (nonatomic,retain) IBOutlet UIImageView *userImage;
@property (nonatomic,retain) IBOutlet UILabel *userNameLabel;

- (void) loadImage;
- (void) refreshWithLike:(Like *)like;

@end
