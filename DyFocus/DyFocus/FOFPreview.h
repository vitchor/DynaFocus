//
//  FOFPreview.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOFPreview : UIViewController {
    
    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    IBOutlet NSMutableArray *frames;
    IBOutlet NSMutableArray *focalPoints;
    
    NSTimer *timer;
    
    int oldFrameIndex;
    int timerPause;
}

@property(nonatomic,retain) IBOutlet UIImageView *firstImageView;
@property(nonatomic,retain) IBOutlet UIImageView *secondImageView;
@property(nonatomic,retain) IBOutlet NSMutableArray *frames;
@property(nonatomic,retain) IBOutlet NSMutableArray *focalPoints;
@property(nonatomic,retain) NSTimer *timer;

-(IBAction)changeSlider:(id)sender;

@end
