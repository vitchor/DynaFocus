//
//  FOFTableCell.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FOFTableController.h"

@interface FOFTableCell : UITableViewCell {

    IBOutlet UILabel *labelUserName;
    IBOutlet UILabel *labelDate;
    
    IBOutlet UIButton *buttonLike;
    IBOutlet UIButton *buttonComment;
    
    IBOutlet UIImageView *imagefrontFrame;
    IBOutlet UIImageView *imagebackFrame;
    IBOutlet UIImageView *imageUserPicture;
    
    IBOutlet UILabel *commentsCountLabel;
    IBOutlet UILabel *likesCountLabel;
    
    IBOutlet UIView *whiteView;
    
    IBOutlet UIActivityIndicatorView *spinner;
    
    FOF *fof;
    
    NSMutableArray *fofUrls;
    NSString *profilePictureUrl;
    
    IBOutlet UIView *lightGrayBrackgroundView;
    
    //FOF *fof;
    NSTimer *timer;
    int oldFrameIndex;
    int timerPause;
    int downloadedFrames;
    
    NSMutableArray *frames;
    
    FOFTableController *tableView;
   
    int row;
    float newHeight;
    
}

-(void) loadImages;

-(void) refreshImageSize;

@property (nonatomic,retain) IBOutlet UILabel *labelUserName;
@property (nonatomic,retain) IBOutlet UILabel *labelDate;

@property (nonatomic,retain) IBOutlet UIButton *buttonLike;
@property (nonatomic,retain) IBOutlet UIButton *buttonComment;

@property (nonatomic,retain) IBOutlet UIImageView *imagefrontFrame;
@property (nonatomic,retain) IBOutlet UIImageView *imagebackFrame;
@property (nonatomic,retain) IBOutlet UIImageView *imageUserPicture;

@property (nonatomic,retain) IBOutlet UILabel *commentsCountLabel;
@property (nonatomic,retain) IBOutlet UILabel *likesCountLabel;

@property (nonatomic,retain) IBOutlet UIView *whiteView;
@property (nonatomic,retain) IBOutlet UIView *lightGrayBrackgroundView;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) FOFTableController *tableView;
@property (nonatomic,readwrite) int row;

- (void) clearImages;
- (void) refreshWithFof:(FOF *)fof;

@end
