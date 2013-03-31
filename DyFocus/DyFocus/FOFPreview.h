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

@interface FOFPreview : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    IBOutlet NSMutableArray *frames;
    IBOutlet NSMutableArray *displayedFrames;
    IBOutlet NSMutableArray *focalPoints;
    IBOutlet UIHorizontalTableView *firstTableView;
    IBOutlet UIHorizontalTableView *secondTableView;    
    NSString *fofName;
    
    NSTimer *timer;
    
    int oldFrameIndex;
    int timerPause;
}

@property(nonatomic,retain) IBOutlet UIImageView *firstImageView;
@property(nonatomic,retain) IBOutlet UIImageView *secondImageView;
@property(nonatomic,retain) IBOutlet NSMutableArray *frames;
@property(nonatomic,retain) IBOutlet NSMutableArray *displayedFrames;
@property(nonatomic,retain) IBOutlet NSMutableArray *focalPoints;
@property(nonatomic,retain) IBOutlet UIHorizontalTableView *firstTableView;
@property(nonatomic,retain) IBOutlet UIHorizontalTableView *secondTableView;
@property(nonatomic,retain) NSTimer *timer;

-(IBAction)changeSlider:(id)sender;

@end
