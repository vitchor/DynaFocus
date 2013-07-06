//
//  FOFPreview.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DyOpenCv/DyOpenCv.h>

#import "AppDelegate.h"

#import "SharingController.h"
#import "FullscreenFOFViewController.h"

#import "UIHorizontalTableView.h"
#import "UIHorizontalTableViewCell.h"
#import "ASIFormDataRequest.h"
#import "FilterUtil.h"
#import "GPUImage.h"

#define CANCEL 0
#define TIMER_INTERVAL 0.1
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL

@interface FOFPreview : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    
    int timerPause;
    int oldFrameIndex;
    bool applyingFilter;

    IBOutlet UIButton *playPauseButton;
    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIHorizontalTableView *firstTableView;
    IBOutlet UIHorizontalTableView *secondTableView;
    
    NSTimer *timer;
    NSString *fofName;
    NSMutableArray *displayedFrames;
}

@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *fixedFrames;
@property(nonatomic,retain) NSMutableArray *focalPoints;

- (IBAction)playPauseAction:(UIButton *)sender;

@end
