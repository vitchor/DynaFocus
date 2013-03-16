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
#import "DyfocusSettings.h"

@interface LoginController ()

@end

@implementation LoginController

@synthesize firstImageView,secondImageView, frames, timer, borderView, facebookConnectButton, leftButton, rightButton, fofs;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self initializeFofs];
        //borderView.layer setCornerRadius
        //borderView.layer.masksToBounds = YES;
        
    }
    return self;
}

- (void)initializeFofs{
    fofs = [[NSMutableArray alloc] initWithCapacity:3];

    NSMutableArray *m_frames0 = [[NSMutableArray alloc] initWithCapacity:3];
    UIImage *frame = [UIImage imageNamed:@"fof_example_00_1.jpeg"];
    [m_frames0 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_00_2.jpeg"];
    [m_frames0 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_00_3.jpeg"];
    [m_frames0 addObject:frame];
    [fofs addObject:m_frames0];
    
    NSMutableArray *m_frames1 = [[NSMutableArray alloc] initWithCapacity:2];
    frame = [UIImage imageNamed:@"fof_example_01_1.jpeg"];
    [m_frames1 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_01_2.jpeg"];
    [m_frames1 addObject:frame];
    [fofs addObject:m_frames1];

    NSMutableArray *m_frames2 = [[NSMutableArray alloc] initWithCapacity:2];
    frame = [UIImage imageNamed:@"fof_example_02_1.jpeg"];
    [m_frames2 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_02_2.jpeg"];
    [m_frames2 addObject:frame];
    [fofs addObject:m_frames2];
    
    NSMutableArray *m_frames3 = [[NSMutableArray alloc] initWithCapacity:2];
    frame = [UIImage imageNamed:@"fof_example_03_1.jpeg"];
    [m_frames3 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_03_2.jpeg"];
    [m_frames3 addObject:frame];
    [fofs addObject:m_frames3];

    fofIndex = 1;
    [self refreshFrames];
}

- (void) refreshFrames{
    frames = [fofs objectAtIndex:fofIndex];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"LoginController.viewDidAppear"];
    
}
- (void)viewDidLoad
{
    NSMutableArray *frames = [fofs objectAtIndex:0];
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
    [leftButton addTarget:self action:@selector(showsPreviousFof) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(showsNextFof) forControlEvents:UIControlEventTouchUpInside];
    

    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];

    
}

- (void) connectWithFacebook {
    DyfocusSettings *settings = [DyfocusSettings sharedSettings];
    settings.isFirstLogin = YES;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate signin];
}

- (void) showsPreviousFof {
    int fofSize = [fofs count];
    fofIndex = fofIndex - 1;
    if (fofIndex < 0) {
        fofIndex = fofSize - 1;
    }
    [self refreshFrames];
    
    oldFrameIndex = 0;
    
    [self.secondImageView setImage:[self.frames objectAtIndex:0]];
    [self.firstImageView setImage:[self.frames objectAtIndex:1]];
}

- (void) showsNextFof {
    int fofSize = [fofs count];
    fofIndex = fofIndex + 1;
    if (fofIndex >= fofSize) {
        fofIndex = 0;
    }
    [self refreshFrames];
    
    oldFrameIndex = 0;
    
    [self.secondImageView setImage:[self.frames objectAtIndex:0]];
    [self.firstImageView setImage:[self.frames objectAtIndex:1]];
}

- (void)fadeImages
{
    if ([frames count] > 0) {
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
