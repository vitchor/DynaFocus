//
//  LoginController.m
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "LoginController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface LoginController ()

@end

@implementation LoginController

@synthesize firstImageView,secondImageView, frames, timer, borderView, facebookConnectButton;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        frames = [[NSMutableArray alloc] initWithCapacity:3];
        
        UIImage *frame = [UIImage imageNamed:@"example_fof_0.jpeg"];
        [frames addObject:frame];
        
        frame = [UIImage imageNamed:@"example_fof_1.jpeg"];
        [frames addObject:frame];
        
        frame = [UIImage imageNamed:@"example_fof_2.jpeg"];
        [frames addObject:frame];
        
       
        
        //borderView.layer setCornerRadius
        //borderView.layer.masksToBounds = YES;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.firstImageView setImage: [self.frames objectAtIndex:0]];
    
    if ([self.frames count] > 1) {
        [self.secondImageView setImage: [self.frames objectAtIndex:1]];
    }
    
    borderView.layer.cornerRadius = 3.0;
    borderView.layer.masksToBounds = YES;
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    [facebookConnectButton addTarget:self action:@selector(connectWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    

    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];

    
}

- (void) connectWithFacebook {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate signin];
    
}

- (void)fadeImages
{
    if (self.firstImageView.alpha >= 1.0) {
        
        if (timerPause > 0) {
            timerPause -= 1;
            
        } else {
            
            timerPause = TIMER_PAUSE;
            
            if (oldFrameIndex >= [self.frames count] - 1) {
                oldFrameIndex = 0;
            } else {
                oldFrameIndex += 1;
            }
            
            
            [self.secondImageView setImage:[self.frames objectAtIndex:oldFrameIndex]];
            
            [self.secondImageView setNeedsDisplay];
            
            [self.firstImageView setAlpha:0.0];
            
            [self.firstImageView setNeedsDisplay];
            
            int newIndex;
            if (oldFrameIndex == [self.frames count] - 1) {
                newIndex = 0;
            } else {
                newIndex = oldFrameIndex + 1;
            }
            
            [self.firstImageView setImage: [self.frames objectAtIndex: newIndex]];
            
        }
        
    } else {
        [self.firstImageView setAlpha:self.firstImageView.alpha + 0.01];
    }
    
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
