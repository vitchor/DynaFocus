
//  FOFPreview.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FOFPreview.h"
#import "ASIFormDataRequest.h"

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
    
    NSString *doneString = @"Upload";
	UIBarButtonItem *continueButton = [[UIBarButtonItem alloc]
									   initWithTitle:doneString style:UIBarButtonItemStyleDone target:self action:@selector(upload)];
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

- (void) upload
{
    
     
     NSString *fof_name = [[NSString alloc] initWithFormat:@"%f",CACurrentMediaTime()];
     
     for (int i = 0; i < [self.frames count]; i++)
     {
     NSLog(@"Uploading image %d",i);
     UIImage *image = [self.frames objectAtIndex:i];
     
     NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.jpg"];
     
     // Write a UIImage to JPEG with minimum compression (best quality)
     [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
     
     NSString *photoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.jpg"];
     
     //NSURL *webServiceUrl = [NSURL URLWithString:@"http://192.168.100.107:8000/uploader/image/"];
     NSURL *webServiceUrl = [NSURL URLWithString:@"http://54.245.121.15//uploader/image/"];
     
     ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:webServiceUrl];
     
     // Add all the post values
     NSString *fof_size = [[NSString alloc] initWithFormat:@"%d",[self.frames count]];
     NSString *frame_index = [[NSString alloc] initWithFormat:@"%d",i];
     
     CGPoint touchPoint = [(NSValue *)[focalPoints objectAtIndex:i] CGPointValue];
     
     [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
     [request setPostValue:frame_index forKey:@"frame_index"];
         
     NSNumber *pointX = [[NSNumber alloc] initWithInt:touchPoint.x*100];
     NSNumber *pointY = [[NSNumber alloc] initWithInt:touchPoint.y*100];
         
     [request setPostValue:pointX forKey:@"frame_focal_point_x"];
     [request setPostValue:pointY forKey:@"frame_focal_point_y"];
         
     [pointX release];
     [pointY release];
     
     [request setPostValue:fof_name forKey:@"fof_name"];
     [request setPostValue:fof_size forKey:@"fof_size"];
     
     // Add the image file to the request
     [request setFile:photoPath withFileName:@"image.jpeg" andContentType:@"Image/jpeg" forKey:@"apiupload"];
     
     [request startSynchronous];
     
     NSLog(@"MESSAGE %@",[request responseString]);
     
     }
    
    [fof_name release];
    
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)fadeImages
{
    NSLog(@"lala");
    
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
