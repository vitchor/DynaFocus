
//  FOFPreview.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FOFPreview.h"
#import "ASIFormDataRequest.h"
#import "SharingController.h"

#define CANCEL 0
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
    

    NSString *cancelString = @"Cancel";
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									   initWithTitle:cancelString style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Preview";
    
    [self.firstImageView setImage: [self.frames objectAtIndex:0]];
    
    if ([self.frames count] > 1) {
        [self.secondImageView setImage: [self.frames objectAtIndex:1]];
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
}

- (void) next {
    SharingController *sharingController;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        sharingController = [[SharingController alloc] initWithNibName:@"SharingController_i5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        sharingController = [[SharingController alloc] initWithNibName:@"SharingController" bundle:nil];
    }
    
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
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) dealloc
{
    //for (UIImage *frame in self.frames) {
    //    [frame release];
    //}
    
    //for (NSValue *point in self.focalPoints) {
    //    [point release];
    //}
         
    [self.frames release];
    [self.focalPoints release];
    [self.firstImageView release];
    [self.secondImageView release];
    
    [super dealloc];
}

- (void) cancel {
	NSString *alertTitle = @"Cancel?";
	NSString *alertMsg =@"You'll lose the picture that you've taken. Are you sure?";
	NSString *alertButton1 = @"Yes";
	NSString *alertButton2 =@"No";
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton1 otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
	[alert setTag:CANCEL];
    [alert addButtonWithTitle:alertButton2];
    [alert show];
	
	[alertTitle release];
	[alertMsg release];
	[alertButton1 release];
	[alertButton2 release];
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == CANCEL) {
        if (buttonIndex == 0) {
			[self.navigationController popViewControllerAnimated:YES];
        }
    }
}

    

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    [super viewWillDisappear:animated];
    
}
@end
