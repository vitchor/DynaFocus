//
//  FullscreenFOFViewController.m
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 4/15/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FullscreenFOFViewController.h"

@implementation FullscreenFOFViewController

@synthesize frames;

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
    
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    bannerView.adUnitID = @"ca-app-pub-4922757350349330/6794918205";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as
    // well as any devices you want to receive test ads.
    request.testDevices = [NSArray arrayWithObjects:@"c7a566cbe07e78e282956d4e44695295", nil];
    
    // Initiate a generic request to load it with an ad.
    [bannerView loadRequest:request];
    
    
//    [bannerView_ loadRequest:[GADRequest request]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    
    if ([self.frames count] > 0) {
        [backImageView setImage: [self.frames objectAtIndex:0]];

        
        if ([self.frames count] > 1) {
            [frontImageView setImage: [self.frames objectAtIndex:1]];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                
                if (oldFrameIndex >= [self.frames count] - 1) {
                    oldFrameIndex = 0;
                } else {
                    oldFrameIndex += 1;
                }
                
                if ([self.frames count] > 0)
                    [backImageView setImage:[self.frames objectAtIndex:oldFrameIndex]];
                
                [backImageView setNeedsDisplay];
                
                [frontImageView setAlpha:0.0];
                
                [frontImageView setNeedsDisplay];
                
                int newIndex;
                if (oldFrameIndex == [self.frames count] - 1) {
                    newIndex = 0;
                } else {
                    newIndex = oldFrameIndex + 1;
                }
                
                if ([self.frames count] > 0)
                    [frontImageView setImage: [self.frames objectAtIndex: newIndex]];
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
    
    if(orientation != lastOrientation || orientation == UIDeviceOrientationUnknown){
        
        if(orientation==UIDeviceOrientationPortrait ||
           orientation==UIDeviceOrientationPortraitUpsideDown ||
           orientation==UIDeviceOrientationLandscapeLeft ||
           orientation==UIDeviceOrientationLandscapeRight)
        {
            lastOrientation = orientation;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationRepeatCount:1];
        
        if (orientation == UIDeviceOrientationPortrait)
        {
            
            backImageView.transform = CGAffineTransformIdentity;
            frontImageView.transform = CGAffineTransformIdentity;
//            bannerView_.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:0.15 animations:^{
                playPauseButton.alpha = 0.0;
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration:0 animations:^{
                    playPauseButton.transform = CGAffineTransformIdentity;
                } completion: ^(BOOL finished) {
                    [self setPlayPauseButtonPlace:orientation];
                }];
            }];
            
//            [bannerView_ setAdSize:kGADAdSizeSmartBannerPortrait];
        }
        else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            backImageView.transform = CGAffineTransformMakeRotation(M_PI);
            frontImageView.transform = CGAffineTransformMakeRotation(M_PI);
//            bannerView_.transform = CGAffineTransformMakeRotation(M_PI);

            
            [UIView animateWithDuration:0.15 animations:^{
                playPauseButton.alpha = 0.0;
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration:0 animations:^{
                    playPauseButton.transform = CGAffineTransformMakeRotation(M_PI);;
                } completion: ^(BOOL finished) {
                    [self setPlayPauseButtonPlace:orientation];
                }];
            }];
            
//            [bannerView_ setAdSize:kGADAdSizeSmartBannerPortrait];
        }
        else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            CGAffineTransform transfRotation = CGAffineTransformMakeRotation(-M_PI_2);
            CGAffineTransform transfScale = CGAffineTransformMakeScale(scale, scale);
            CGAffineTransform transfConcat = CGAffineTransformConcat(transfScale, transfRotation);
            
            backImageView.transform = transfConcat;
            frontImageView.transform = transfConcat;
//            bannerView_.transform = transfRotation;
            
            [UIView animateWithDuration:0.15 animations:^{
                playPauseButton.alpha = 0.0;
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration:0 animations:^{
                    playPauseButton.transform = transfRotation;
                } completion: ^(BOOL finished) {
                    [self setPlayPauseButtonPlace:orientation];
                }];
            }];
            
//            [bannerView_ setAdSize:kGADAdSizeSmartBannerLandscape];
        }
        else if(orientation == UIDeviceOrientationLandscapeLeft)
        {
            CGAffineTransform transfRotation = CGAffineTransformMakeRotation(M_PI_2);
            CGAffineTransform transfScale = CGAffineTransformMakeScale(scale, scale);
            CGAffineTransform transfConcat = CGAffineTransformConcat(transfRotation, transfScale);
            
            backImageView.transform = transfConcat;
            frontImageView.transform = transfConcat;
//            bannerView_.transform = transfRotation;
            
            [UIView animateWithDuration:0.15 animations:^{
                playPauseButton.alpha = 0.0;
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration:0 animations:^{
                    playPauseButton.transform = transfRotation;
                } completion: ^(BOOL finished) {
                    [self setPlayPauseButtonPlace:orientation];
                }];
            }];
            
//            [bannerView_ setAdSize:kGADAdSizeSmartBannerLandscape];
        }
        else if(orientation == UIDeviceOrientationUnknown)
        {
            backImageView.transform = CGAffineTransformIdentity;
            frontImageView.transform = CGAffineTransformIdentity;
//            bannerView_.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:0.15 animations:^{
                playPauseButton.alpha = 0.0;
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration:0 animations:^{
                    playPauseButton.transform = CGAffineTransformIdentity;
                } completion: ^(BOOL finished) {
                    [self setPlayPauseButtonPlace:orientation];
                }];
            }];
            
//            [bannerView_ setAdSize:kGADAdSizeSmartBannerPortrait];
        }
        else if(firstTime && (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown))
        {
            backImageView.transform = CGAffineTransformIdentity;
            frontImageView.transform = CGAffineTransformIdentity;
//            bannerView_.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:0.15 animations:^{
                playPauseButton.alpha = 0.0;
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration:0 animations:^{
                    playPauseButton.transform = CGAffineTransformIdentity;
                } completion: ^(BOOL finished) {
                    [self setPlayPauseButtonPlace:UIDeviceOrientationPortrait];
                }];
            }];
            
//            [bannerView_ setAdSize:kGADAdSizeSmartBannerPortrait];
        }
        
        [UIView commitAnimations];
    }
}


-(void) setPlayPauseButtonPlace:(UIDeviceOrientation) orientation {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {

        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationUnknown)
        {
            playPauseButtonX.constant = 6.0;
            playPauseButtonY.constant = 6.0;//+65.0
        }
        else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            playPauseButtonX.constant = 274.0;
            playPauseButtonY.constant = 435.0+22.0+65.0;
        }
        else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            playPauseButtonX.constant = 6.0;
            playPauseButtonY.constant = 434.0+88.0;
        }
        else if(orientation == UIDeviceOrientationLandscapeLeft)
        {
            playPauseButtonX.constant = 274.0;
            playPauseButtonY.constant = 6.0;
        }

    } else {
    
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationUnknown)
        {
            playPauseButtonX.constant = 6.0;
            playPauseButtonY.constant = 27.0;
        }
        else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            playPauseButtonX.constant = 274.0;
            playPauseButtonY.constant = 435.0-22.0;
        }
        else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            playPauseButtonX.constant = 6.0;
            playPauseButtonY.constant = 434.0;
        }
        else if(orientation == UIDeviceOrientationLandscapeLeft)
        {
            playPauseButtonX.constant = 274.0;
            playPauseButtonY.constant = 6.0;
        }
    }

    [UIView animateWithDuration:0.15 animations:^{
        playPauseButton.alpha = 0.5;
    }];
}


- (IBAction)playPauseAction:(UIButton *)sender {
    
    if (timer)
    {
        [timer invalidate];
        timer = nil;
        
        [playPauseButton setImage:[UIImage imageNamed:@"Play-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
    else
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
        [timer fire];
        
        [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    
    [fullscreenImageHeight release];
    [fullscreenImageWidth release];
    [playPauseButtonX release];
    [playPauseButtonY release];
    
    [frontImageView release];
    [backImageView release];
    
    [playPauseButton release];
    
    [timer release];
    
    [bannerView release];
    
    [frames release], frames = nil;
    
    [super dealloc];
}

@end
