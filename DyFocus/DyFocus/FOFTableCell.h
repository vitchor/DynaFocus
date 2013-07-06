//
//  FOFTableCell.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#import "AppDelegate.h"

#import "FOFTableController.h"
#import "FullscreenFOFViewController.h"

#import "JSON.h"
#import "LoadView.h"
#import "NSDyfocusURLRequest.h"
#import "UIDyfocusImage.h"
#import "UIImageLoaderDyfocus.h"

//Space occupied by the header and footer in the cell:
#define HEADER_AND_FOOTER_HEIGHT 122

//Offset for Play/Pause Button position
#define PLAY_PAUSE_BUTTON_OFFSET 35

//Offset for Description Label position
#define DESCRIPTION_LABEL_OFFSET 62

//Offset for Read More Label position
#define READMORE_LABEL_OFFSET PREVIEW_N_LINES * LINE_HEIGHT - 28

//Description Label Settings
#define PREVIEW_N_LINES 3 //// ---> number of lines for preview text, i.e, the text before "read more".
#define MAX_LINES 10
#define LINE_HEIGHT 18
#define MAX_FRAME_HEIGHT MAX_LINES * LINE_HEIGHT

//Timer Settings
#define TIMER_INTERVAL 0.1
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL

@interface FOFTableCell : UITableViewCell {
    
    int timerPause;
    int oldFrameIndex;
    int downloadedFrames;
    float newImageHeight;
    float newDescriptionHeight;

    IBOutlet UIView *whiteView;
    IBOutlet UIView *supportView;
    IBOutlet UIView *lightGrayBackgroundView;
   
    IBOutlet UIImageView *imageUserPicture;
    IBOutlet UIImageView *imagefrontFrame;
    IBOutlet UIImageView *imagebackFrame;

    IBOutlet UIButton *deleteFOFButton;
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIButton *buttonLike;
    IBOutlet UIButton *buttonComment;
    
    IBOutlet UILabel *labelUserName;
    IBOutlet UILabel *labelDate;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UILabel *readMoreLabel;
    IBOutlet UILabel *commentsCountLabel;
    IBOutlet UILabel *likesCountLabel;
   
    IBOutlet UIActivityIndicatorView *spinner;
    
    NSString *profilePictureUrl;
    NSMutableArray *frames;
    NSMutableArray *fofUrls;
    NSTimer *timer;
    
    FOF *fof;
}

@property (nonatomic,readwrite) int row;
@property (nonatomic,retain) NSString *descriptionFullText;
@property (nonatomic,retain) NSMutableString *descriptionPreviewText;
@property (nonatomic,retain) FOFTableController *tableView;

- (void) loadImages;
- (void) increaseCommentsCounter;
- (void) decreaseCommentsCounter;
- (void) refreshImageSize;
- (void) refreshWithFof:(FOF *)fof;
- (IBAction) playPauseAction:(UIButton *)sender;

@end
