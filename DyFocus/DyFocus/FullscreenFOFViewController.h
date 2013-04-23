//
//  FullscreenFOFViewController.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 4/15/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FOFTableCell.h"

@interface FullscreenFOFViewController : UIViewController <UIGestureRecognizerDelegate>{
    
    IBOutlet NSLayoutConstraint *fullscreenImageHeight;
    IBOutlet NSLayoutConstraint *fullscreenImageWidth;
    IBOutlet UIImageView *frontImageView;
    IBOutlet UIImageView *backImageView;
    
    NSMutableArray *frames;
    
    NSTimer *timer;
    int oldFrameIndex;
    int timerPause;
}

@property(nonatomic,retain) IBOutlet NSMutableArray *frames;

@end