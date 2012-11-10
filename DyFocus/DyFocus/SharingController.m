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
    self.navigationItem.title = @"Publish";
    
    [activityIndicator removeFromSuperview];

    NSString *share = @"Publish";
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:share style:UIBarButtonItemStyleDone target:self action:@selector(share)];
	self.navigationItem.rightBarButtonItem = shareButton;
	[shareButton release];
	[share release];
    
    [facebookSwitch addTarget: self action: @selector(changedSwitchValue:) forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction) changedSwitchValue: (id) sender {
    
    UISwitch *fbSwitch = (UISwitch *)sender;
    
    if (fbSwitch.on) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // To-do, show logged in view
        } else if (FBSession.activeSession.state != FBSessionStateOpen) {
            // No, display the login page.
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate openSession];
        }
    }
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state)         {
        case FBSessionStateOpen:
            if (!error)         {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [session closeAndClearTokenInformation];
            
            //[self createNewSession];
            break;
        default:
            break;
    }
}
-(void)share
{
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    [spinner startAnimating];
    
    [self upload];
    
    return;
}

-(void)shareWithFacebook {
    
    NSString *deviceIdentifier =[[UIDevice currentDevice] uniqueIdentifier];
    NSString *urlLink = [[NSString alloc] initWithFormat:@"http://dyfoc.us/uploader/%@/user/%@/fof_name/", deviceIdentifier, fofName];
    
    NSString *message = @"";
    
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"http://s3.amazonaws.com/dyfocus/%@_%@_0.jpeg",deviceIdentifier, fofName];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   urlLink, @"link",
                                   message,@"message",
                                   imageUrl,@"picture",
                                   nil];
    [urlLink release];
    [imageUrl release];
    
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        [activityIndicator removeFromSuperview];
        
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
    
   

    //[FBSession requestWithGraphPath:@"me/links" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) upload
{
    NSLog(@"aaa");
    
    NSURL *webServiceUrl = [NSURL URLWithString:@"http://dyfoc.us/uploader/image/"];
    //NSURL *webServiceUrl = [NSURL URLWithString:@"http://192.168.0.108:8000/uploader/image/"];
    
    request = [[ASIFormDataRequest requestWithURL:webServiceUrl] retain];
    [request setDelegate:self];
    
    fofName = [[NSString alloc] initWithFormat:@"%f",CACurrentMediaTime()];
    NSString *fof_size = [[[NSString alloc] initWithFormat:@"%d",[self.frames count]] autorelease];
    
    [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
    [request setPostValue:fofName forKey:@"fof_name"];
    [request setPostValue:fof_size forKey:@"fof_size"];
    
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
    [activityIndicator removeFromSuperview];
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
    [activityIndicator removeFromSuperview];
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


-(void)requestUserInfo:(FBSession *)session {
    
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSError *error;
                 NSURLResponse *response;
                 NSHTTPURLResponse *httpResponse;
                 NSData *dataReply;
                 id stringReply;
             
                 NSURL *webServiceUrl = [NSURL URLWithString:@"http://dyfoc.us/uploader/user_fb_info/"];
               
                 NSString *postString = [[NSString alloc] initWithFormat:@"facebook_id=%@&name=%@&email=%@&device_id=%@", user.id, user.name, [user objectForKey:@"email"], [[UIDevice currentDevice] uniqueIdentifier]];
                 
                 NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:webServiceUrl];
                 
                 [postRequest setHTTPMethod:@"POST"];

                 [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 dataReply = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
                 stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
                 // Some debug code, etc.
                 NSLog(@"reply from server: %@", stringReply);
                 httpResponse = (NSHTTPURLResponse *)response;
                 int statusCode = [httpResponse statusCode];
                 NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]);
                 NSLog(@"HTTP Status code: %d", statusCode);
                 
                 
                 [postString release];
             }
         }];
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
