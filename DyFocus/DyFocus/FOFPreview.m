
//  FOFPreview.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FOFPreview.h"
#import "ASIFormDataRequest.h"
#import "SharingController.h"

@implementation FOFPreview

@synthesize firstImageView,secondImageView, frames, focalPoints, timer;

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    NSString *doneString = @"Next";
	UIBarButtonItem *continueButton = [[UIBarButtonItem alloc]
									   initWithTitle:doneString style:UIBarButtonItemStyleDone target:self action:@selector(next)];
	self.navigationItem.rightBarButtonItem = continueButton;
	[continueButton release];
	[doneString release];
    
    [super viewDidLoad];
    
    [self.firstImageView setImage: [self.frames objectAtIndex:0]];
    
    if ([self.frames count] > 1) {
        [self.secondImageView setImage: [self.frames objectAtIndex:1]];
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
}

- (void) next {
    SharingController *sharingController = [[SharingController alloc] initWithNibName:@"SharingController" bundle:nil];
    
    sharingController.focalPoints = focalPoints;
    sharingController.frames = frames;
    
    [self.navigationController pushViewController:sharingController animated:true];
    
    [sharingController release];
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

- (void)viewDidUnload
{

    [self dealloc];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
   
    [super viewDidAppear:animated];
}

- (void) dealloc
{
    for (UIImage *frame in self.frames) {
        [frame release];
    }
    
    for (NSValue *point in self.focalPoints) {
        [point release];
    }
         
    
    [self.firstImageView release];
    [self.secondImageView release];
    NSLog(@"YEAAAH");
    
    [super dealloc];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    [super viewWillDisappear:animated];
    
}
@end
