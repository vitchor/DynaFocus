//
//  FullscreenFOFViewController.m
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 4/15/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FullscreenFOFViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FullscreenFOFViewController ()

@end

@implementation FullscreenFOFViewController

@synthesize frames;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popController)];
    [self.view addGestureRecognizer:tapView];
    [tapView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if ([frames count] > 0) {
        [backImageView setImage: [frames objectAtIndex:0]];

        
        if ([frames count] > 1) {
            [frontImageView setImage: [frames objectAtIndex:1]];
        }
        
        float scale = backImageView.image.size.width/backImageView.image.size.height;
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        fullscreenImageWidth.constant = screenBounds.size.width;
        fullscreenImageHeight.constant = screenBounds.size.width/scale;
        
        oldFrameIndex = 0;
        timerPause = TIMER_INTERVAL;
        
        if(timer){
            [timer invalidate];
            timer = nil;
        }
            
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
        [timer fire];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [self checkOrientation:scale isFirstTime:YES];
    }
    else
    {
        [self popController];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    frames  = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [fullscreenImageHeight release];
    [fullscreenImageWidth release];
    [frontImageView release];
    [backImageView release];
    [frames release];

    [super dealloc];
}

- (void) popController
{
    [self.view setUserInteractionEnabled:NO];
    
    backImageView.transform = CGAffineTransformIdentity;
    frontImageView.transform = CGAffineTransformIdentity;
    
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:
         UIViewAnimationTransitionFlipFromLeft
                               forView:self.navigationController.view cache:NO];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        [UIView commitAnimations];
}

- (void)fadeImages {
        
        if (frontImageView.alpha >= 1.0) {
            
            if (timerPause > 0) {
                timerPause -= 1;
                
            } else {
                
                timerPause = TIMER_PAUSE;
                
                if (oldFrameIndex >= [frames count] - 1) {
                    oldFrameIndex = 0;
                } else {
                    oldFrameIndex += 1;
                }
                
                if ([frames count] > 0)
                    [backImageView setImage:[frames objectAtIndex:oldFrameIndex]];
                
                [backImageView setNeedsDisplay];
                
                [frontImageView setAlpha:0.0];
                
                [frontImageView setNeedsDisplay];
                
                int newIndex;
                if (oldFrameIndex == [frames count] - 1) {
                    newIndex = 0;
                } else {
                    newIndex = oldFrameIndex + 1;
                }
                
                if ([frames count] > 0)
                    [frontImageView setImage: [frames objectAtIndex: newIndex]];
            }
            
        } else {
            [frontImageView setAlpha:frontImageView.alpha + 0.01];
        }
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (void) didRotate:(NSNotification *)notification
{
    float scale = backImageView.image.size.width/backImageView.image.size.height;
    
    [self checkOrientation:scale isFirstTime:NO];
}

- (void) checkOrientation:(float)scale isFirstTime:(BOOL)firstTime
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:1];
    
    if (orientation == UIDeviceOrientationPortrait)
    {
        backImageView.transform = CGAffineTransformIdentity;
        frontImageView.transform = CGAffineTransformIdentity;
    }
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        backImageView.transform = CGAffineTransformMakeRotation(M_PI);
        frontImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else if(orientation == UIDeviceOrientationLandscapeRight)
    {
        CGAffineTransform transfRotation = CGAffineTransformMakeRotation(-M_PI_2);
        CGAffineTransform transfScale = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform transfConcat = CGAffineTransformConcat(transfScale, transfRotation);
        
        backImageView.transform = transfConcat;
        frontImageView.transform = transfConcat;
    }
    else if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        CGAffineTransform transfRotation = CGAffineTransformMakeRotation(M_PI_2);
        CGAffineTransform transfScale = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform transfConcat = CGAffineTransformConcat(transfRotation, transfScale);
        
        backImageView.transform = transfConcat;
        frontImageView.transform = transfConcat;
    }
    else if(orientation == UIDeviceOrientationUnknown)
    {
        backImageView.transform = CGAffineTransformIdentity;
        frontImageView.transform = CGAffineTransformIdentity;
    }
    else if(firstTime && (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown))
    {
        backImageView.transform = CGAffineTransformIdentity;
        frontImageView.transform = CGAffineTransformIdentity;
    }
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
