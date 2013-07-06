//
//  FullscreenFOFViewController.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 4/15/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullscreenFOFViewController : UIViewController{
    
    IBOutlet NSLayoutConstraint *fullscreenImageHeight;
    IBOutlet NSLayoutConstraint *fullscreenImageWidth;
    IBOutlet UIImageView *frontImageView;
    IBOutlet UIImageView *backImageView;
    IBOutlet UIButton *playPauseButton;
    IBOutlet NSLayoutConstraint *playPauseButtonX;
    IBOutlet NSLayoutConstraint *playPauseButtonY;

    UIDeviceOrientation lastOrientation;
    NSMutableArray *frames;
    NSTimer *timer;
    
    int oldFrameIndex;
    int timerPause;
}

@property(nonatomic,assign) NSMutableArray *frames;

- (IBAction)playPauseAction:(UIButton *)sender;

@end
