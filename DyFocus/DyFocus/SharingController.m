//
//  SharingController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "SharingController.h"
#import <FacebookSDK/FacebookSDK.h>
#import"AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "LoadView.h"
#import "UIImage+fixOrientation.h"

@interface SharingController ()

@end

@implementation SharingController

@synthesize facebookSwitch, activityIndicator, frames, focalPoints, spinner;

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
    self.navigationItem.title = @"Upload";
 
    NSString *share = @"Upload";
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:share style:UIBarButtonItemStyleDone target:self action:@selector(share)];
	self.navigationItem.rightBarButtonItem = shareButton;
	[shareButton release];
	[share release];
    
    
}


- (void) share {
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    [self showLoading];
        
    [self upload];
}

- (void) showLoading {
    [activityIndicator setHidden:NO];
    [self.view bringSubviewToFront:activityIndicator];
    [spinner startAnimating];
}

-(void)shareWithFacebook {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSString *savedFacebookId = [appDelegate.myself objectForKey:@"id"];
    
    NSString *urlLink = [[NSString alloc] initWithFormat:@"http://dyfoc.us/uploader/%@/share_fof/", fofName];
    
    NSString *message = @"";
    
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"http://s3.amazonaws.com/dyfocus/%@_%@_0.jpeg",savedFacebookId, fofName];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   urlLink, @"link",
                                   message,@"message",
                                   imageUrl,@"picture",
                                   nil];
    [urlLink release];
    [imageUrl release];
    
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        [activityIndicator setHidden:YES];
        
        if (!error) {
            //[self.navigationController popViewControllerAnimated:YES];
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate resetCameraUINavigationController];
        } else {
            facebookSwitch.on = false;
            NSString *alertTitle = @"Connection Error";
            NSString *alertMsg = @"Failed to share link on your Facebook wall.";
            NSString *alertButton = @"OK";
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
            [alert show];
            
            [alertTitle release];
            [alertMsg release];
            [alertButton release];
            
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) upload
{
    
    NSURL *webServiceUrl = [NSURL URLWithString:@"http://dyfoc.us/uploader/image/"];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    NSString *savedFacebookId = [appDelegate.myself objectForKey:@"id"];
    NSString *savedFacebookName = [appDelegate.myself objectForKey:@"name"];
    NSString *savedFacebookEmail = [appDelegate.myself objectForKey:@"email"];
    
    request = [[ASIFormDataRequest requestWithURL:webServiceUrl] retain];
    [request setDelegate:self];
    
    fofName = [[NSString alloc] initWithFormat:@"%f",CACurrentMediaTime()];
    NSString *fof_size = [[[NSString alloc] initWithFormat:@"%d",[self.frames count]] autorelease];
    
    [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
    [request setPostValue:fofName forKey:@"fof_name"];
    [request setPostValue:fof_size forKey:@"fof_size"];
    [request setPostValue:savedFacebookId forKey:@"facebook_id"];
    [request setPostValue:savedFacebookName forKey:@"facebook_name"];
    [request setPostValue:savedFacebookEmail forKey:@"facebook_email"];
    
    for (int i = 0; i < [self.frames count]; i++)
    {
        NSLog(@"Uploading image %d",i);
        UIImage *image = [[self.frames objectAtIndex:i] fixOrientation];
        
        NSString *imagePath = [[NSString alloc] initWithFormat:@"Documents/image_%d.jpg", i];
        
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:imagePath];
        
        // Write a UIImage to JPEG with minimum compression (best quality)
        [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
        
        NSString *photoPath = [NSHomeDirectory() stringByAppendingPathComponent:imagePath];
        
        
        // Add all the post values
        
        CGPoint touchPoint = [(NSValue *)[focalPoints objectAtIndex:i] CGPointValue];
        
        NSNumber *pointX = [[NSNumber alloc] initWithInt:touchPoint.x*100];
        NSNumber *pointY = [[NSNumber alloc] initWithInt:touchPoint.y*100];
        
        NSString *frameFocalPointX = [[NSString alloc] initWithFormat:@"frame_focal_point_x_%d", i];
        NSString *frameFocalPointY = [[NSString alloc] initWithFormat:@"frame_focal_point_y_%d", i];
        
        [request setPostValue:pointX forKey:frameFocalPointX];
        [request setPostValue:pointY forKey:frameFocalPointY];
        
        [pointX release];
        [pointY release];
        
        NSString *fileName = [[NSString alloc] initWithFormat:@"image_%d.jpeg", i];
        NSString *keyName = [[NSString alloc] initWithFormat:@"apiupload_%d", i];
        
        // Add the image file to the request
        [request setFile:photoPath withFileName:fileName andContentType:@"Image/jpeg" forKey:keyName];
        
        [fileName release];
        [keyName release];
        [frameFocalPointX release];
        [frameFocalPointY release];
        [imagePath release];
        //[fof_size release];

    }
    

    
    [request startAsynchronous];
    NSLog(@"MESSAGE %@",[request responseString]);
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"REQUEST FINISHED");
    
    if (facebookSwitch.on) {
        [self shareWithFacebook];
    } else {
        //[self.navigationController popViewControllerAnimated:YES];
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate resetCameraUINavigationController];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [activityIndicator setHidden:YES];
    NSLog(@"REQUEST FAILED");
    
    self.navigationItem.rightBarButtonItem.enabled = true;
    
    NSString *alertTitle = @"Request Failed";
    NSString *alertMsg = @"Check your internet connection and try again.";
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton release];
}

- (void)requestRedirected:(ASIHTTPRequest *)request {
    [activityIndicator setHidden:YES];
    NSLog(@"REQUEST REDIRECTED");    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (request) {
        [request setDelegate:nil];
        [request cancel];
        [request release];
    }
}

-(void) facebookError
{
    facebookSwitch.on = false;
    NSString *alertTitle = @"Connection Error";
    NSString *alertMsg = @"Failed to connect to Facebook.";
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton release];
    
}

-(void)dealloc
{
    [frames release];
    [focalPoints release];
    [fofName release];
    [super dealloc];
}

@end
