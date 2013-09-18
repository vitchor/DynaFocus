//
//  FullscreenFOFViewController.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 4/15/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//#import "GADBannerView.h"
//#import "GADRequest.h"

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

@interface FullscreenFOFViewController : UIViewController{
    
    int oldFrameIndex;
    int timerPause;
    
    IBOutlet NSLayoutConstraint *fullscreenImageHeight;
    IBOutlet NSLayoutConstraint *fullscreenImageWidth;
    IBOutlet NSLayoutConstraint *playPauseButtonX;
    IBOutlet NSLayoutConstraint *playPauseButtonY;
    
    IBOutlet UIImageView *frontImageView;
    IBOutlet UIImageView *backImageView;
    
    IBOutlet UIButton *playPauseButton;
    
    UIDeviceOrientation lastOrientation;
    NSTimer *timer;
    
//    GADBannerView *bannerView;
}

@property(nonatomic,retain) NSMutableArray *frames;

- (IBAction)playPauseAction:(UIButton *)sender;

@end
