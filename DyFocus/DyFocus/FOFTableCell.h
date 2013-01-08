//
//  FOFTableCell.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FOFTableCell : UITableViewCell {

    IBOutlet UILabel *labelUserName;
    IBOutlet UILabel *labelDate;
    IBOutlet UIButton *buttonLike;
    IBOutlet UIButton *buttonComment;
    IBOutlet UIImageView *imagefrontFrame;
    IBOutlet UIImageView *imagebackFrame;
    IBOutlet UIImageView *imageUserPicture;
    
    IBOutlet UIActivityIndicatorView *spinner;
    
    
    NSMutableArray *fofUrls;
    NSString *profilePictureUrl;
    
    //FOF *fof;
    NSTimer *timer;
    int oldFrameIndex;
    int timerPause;
    int downloadedFrames;
    
    NSMutableArray *frames;
    
}

-(void) loadImages;

@property (nonatomic,retain) IBOutlet UILabel *labelUserName;
@property (nonatomic,retain) IBOutlet UILabel *labelDate;
@property (nonatomic,retain) IBOutlet UIButton *buttonLike;
@property (nonatomic,retain) IBOutlet UIButton *buttonComment;
@property (nonatomic,retain) IBOutlet UIImageView *imagefrontFrame;
@property (nonatomic,retain) IBOutlet UIImageView *imagebackFrame;
@property (nonatomic,retain) IBOutlet UIImageView *imageUserPicture;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,retain) NSTimer *timer;

- (void) refreshWithFof:(FOF *)fof;

@end
