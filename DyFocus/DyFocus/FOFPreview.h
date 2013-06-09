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

@interface FOFPreview : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate> {
    
    IBOutlet UIHorizontalTableView *firstTableView;
    IBOutlet UIHorizontalTableView *secondTableView;
    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    IBOutlet UIScrollView *scrollView;
    
    NSMutableArray *fixedFrames;
    NSMutableArray *frames;
    NSMutableArray *displayedFrames;
    NSMutableArray *focalPoints;
    NSTimer *timer;
    NSString *fofName;

    int oldFrameIndex;
    int timerPause;
    IBOutlet UIButton *playPauseButton;
}

@property(nonatomic,retain) IBOutlet UIHorizontalTableView *firstTableView;
@property(nonatomic,retain) IBOutlet UIHorizontalTableView *secondTableView;
@property(nonatomic,retain) IBOutlet UIImageView *firstImageView;
@property(nonatomic,retain) IBOutlet UIImageView *secondImageView;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) NSMutableArray *fixedFrames;
@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *displayedFrames;
@property(nonatomic,retain) NSMutableArray *focalPoints;
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) NSString *fofName;

@property(nonatomic, assign) int oldFrameIndex;
@property(nonatomic, assign) int timerPause;

- (IBAction)changeSlider:(id)sender;
- (IBAction)playPauseAction:(UIButton *)sender;

@end
