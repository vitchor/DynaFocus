//
//  PageControlFOFViewController.h
//  DyFocus
//
//  Created by Victor on 4/28/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

@interface PageControlFOFViewController : UIViewController {

    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    IBOutlet NSMutableArray *frames;
    IBOutlet UILabel *messageLabel;
    
    IBOutlet UILabel *pageNumberLabel;
    int pageNumber;
    
    NSTimer *timer;
    
    int fofIndex;
    int oldFrameIndex;
    int timerPause;
    
}

@property (nonatomic, retain) UILabel *pageNumberLabel;
@property(nonatomic,retain) IBOutlet UIImageView *firstImageView;
@property(nonatomic,retain) IBOutlet UIImageView *secondImageView;
@property(nonatomic,retain) IBOutlet NSMutableArray *frames;
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) IBOutlet UILabel *messageLabel;

- (id)initWithPageNumber:(int)page;

@end
