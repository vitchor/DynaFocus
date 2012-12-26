//
//  LoginController.h
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController {
    
    IBOutlet UIImageView *firstImageView;
    IBOutlet UIImageView *secondImageView;
    
    IBOutlet UIButton *facebookConnectButton;
    IBOutlet UIView *borderView;
    IBOutlet NSMutableArray *frames;
    NSString *fofName;
    
    NSTimer *timer;
    
    int oldFrameIndex;
    int timerPause;
}

@property(nonatomic,retain) IBOutlet UIImageView *firstImageView;
@property(nonatomic,retain) IBOutlet UIButton *facebookConnectButton;

@property(nonatomic,retain) IBOutlet UIImageView *secondImageView;
@property(nonatomic,retain) IBOutlet UIView *borderView;
@property(nonatomic,retain) IBOutlet NSMutableArray *frames;
@property(nonatomic,retain) IBOutlet NSMutableArray *focalPoints;
@property(nonatomic,retain) NSTimer *timer;

@end