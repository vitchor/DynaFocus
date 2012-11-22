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

@synthesize facebookSwitch, activityIndicator, frames, focalPoints, spinner, facebookLoginView, cancelFacebookLoginButton, continueToFacebookLoginButton;

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
    
    [cancelFacebookLoginButton addTarget:self action:@selector(cancelFacebookLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [continueToFacebookLoginButton addTarget:self action:@selector(continueToFacebookLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];

    NSString *share = @"Publish";
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:share style:UIBarButtonItemStyleDone target:self action:@selector(share)];
	self.navigationItem.rightBarButtonItem = shareButton;
	[shareButton release];
	[share release];
    
    [facebookSwitch addTarget: self action: @selector(changedSwitchValue:) forControlEvents:UIControlEventValueChanged];
    
}

- (void) cancelFacebookLoginButtonAction {
    self.navigationItem.rightBarButtonItem.enabled = true;
    [facebookLoginView setHidden:YES];
}

- (void) continueToFacebookLoginButtonAction {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openFacebookSessionWithTag:UPLOADING];
    
    [facebookLoginView setHidden:YES];
}


- (IBAction) changedSwitchValue: (id) sender {
    
    UISwitch *fbSwitch = (UISwitch *)sender;
    
    if (fbSwitch.on) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // To-do, show logged in view
        } else if (FBSession.activeSession.state != FBSessionStateOpen) {
            // No, display the login page.
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate openFacebookSessionWithTag:SHARING];
        }
    }
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state)         {
        case FBSessionStateOpen:
            if (!error) {
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
- (void) share
{
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedId = [defaults stringForKey:@"UserFacebookId"];
    
    if (savedId) {
        [self showLoading];
        
        [self upload];
        
    } else {
        
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            
            [self showLoading];
            
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 
                 if (!error) {
                     
                     [self saveUserDefaults:user];
                     [self upload];
                     
                 } else {
                     [self facebookError];
                 }
             }];
            
        } else {
            
            //We don't have a session or an ID
            [facebookLoginView setHidden:NO];
        }
    }
    
}

- (void) showLoading {
    [activityIndicator setHidden:NO];
    [self.view bringSubviewToFront:activityIndicator];
    [spinner startAnimating];
}

- (void) saveUserDefaults: (NSDictionary<FBGraphUser> *)user {
    
    NSLog(@"SAVING DEFAULTS");
    NSLog(@"NAME: %@", user.name);
    NSLog(@"ID: %@", user.id);
    NSLog(@"EMAIl: %@", [user objectForKey:@"email"]);
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"email"] forKey:@"UserFacebookEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:@"UserFacebookName"];
    [[NSUserDefaults standardUserDefaults] setObject:user.id forKey:@"UserFacebookId"];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate loadFeedUrl:user.id];
}


-(void)shareWithFacebook {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedFacebookId = [defaults stringForKey:@"UserFacebookId"];
    
    NSString *urlLink = [[NSString alloc] initWithFormat:@"http://dyfoc.us/uploader/%@/user/%@/fof_name/", savedFacebookId, fofName];
    
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
    //NSURL *webServiceUrl = [NSURL URLWithString:@"http://192.168.0.108:8000/uploader/image/"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedFacebookId = [defaults stringForKey:@"UserFacebookId"];
    NSString *savedFacebookName = [defaults stringForKey:@"UserFacebookName"];
    NSString *savedFacebookEmail = [defaults stringForKey:@"UserFacebookEmail"];
    
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


-(void)requestUserInfo:(FBSession *)session withTag:(int)tag {
    
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error) {
         if (!error) {
             
             [self saveUserDefaults:user];
             
             if (tag == UPLOADING) {
                 [self showLoading];
                 [self upload];
             }
             
         } else {
             [self facebookError];
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
