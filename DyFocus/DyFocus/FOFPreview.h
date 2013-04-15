//
//  FOFPreview.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIHorizontalTableView.h"
#import "UIHorizontalTableViewCell.h"

@interface FOFPreview : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
    
    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    IBOutlet UIImageView *firstImageViewFullScreen;
    IBOutlet UIImageView *secondImageViewFullScreen;
    IBOutlet UIView *fullScreenView;
    IBOutlet UIHorizontalTableView *firstTableView;
    IBOutlet UIHorizontalTableView *secondTableView;
    IBOutlet UIScrollView *scrollView;
    
    NSMutableArray *frames;
    NSMutableArray *displayedFrames;
    NSMutableArray *focalPoints;
    NSString *fofName;
    NSTimer *timer;
    UITapGestureRecognizer *tapScrollView;
    UITapGestureRecognizer *tapFullScreenView;

    
    BOOL isFullScreen;
    int oldFrameIndex;
    int timerPause;
}

@property(nonatomic,retain) IBOutlet UIImageView *firstImageView;
@property(nonatomic,retain) IBOutlet UIImageView *secondImageView;
@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *displayedFrames;
@property(nonatomic,retain) NSMutableArray *focalPoints;
@property(nonatomic,retain) IBOutlet UIHorizontalTableView *firstTableView;
@property(nonatomic,retain) IBOutlet UIHorizontalTableView *secondTableView;
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;

-(IBAction)changeSlider:(id)sender;

@end
