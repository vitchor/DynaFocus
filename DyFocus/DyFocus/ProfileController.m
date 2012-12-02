//
//  ProfileController.m
//  DyFocus
//
//  Created by Alexandre Cordeiro on 8/30/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "ProfileController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface ProfileController ()

@end

@implementation ProfileController


@synthesize facebookLoginView, logoutButton, loginButton, dyfocusProfileView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen) {
        //NSLog(@"Yay, dude! FB Session is active :)");
        [self requestUserInfo];
        [facebookLoginView removeFromSuperview];
        //[self.view addSubview:dyfocusProfileView];
        //[self.view bringSubviewToFront:dyfocusProfileView];
    } else {
        NSLog(@"FB Session Not Active");
        //[dyfocusProfileView removeFromSuperview];
        [self.view addSubview:facebookLoginView];
        [self.view bringSubviewToFront:facebookLoginView];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";

    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
}

- (void)resetView
{
    UIView *parent = self.view.superview;
    [self.view removeFromSuperview];
    self.view = nil; // unloads the view
    [parent addSubview:self.view]; //reloads the view from the nib
}

- (void)login
{
    NSLog(@"logging in");
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];

    [appDelegate openSessionWithAllowLoginUI:YES];

    [self requestUserInfo];
    
    [self resetView];
    return;
}


- (void)logout
{
    NSLog(@"logging out");
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    // If the user is authenticated, log out when the button is clicked.
    // If the user is not authenticated, log in when the button is clicked.
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    
    [self resetView];    
    
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

- (void)requestUserInfo {
    if (FBSession.activeSession.isOpen) {
        NSLog(@"Requesting user info");
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSLog(@"Found an user whose name is %@", user.name);
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = user.id;
             }
         }];
    }
    
}

-(void) facebookError
{
    NSString *alertTitle = @"Connection Error";
    NSString *alertMsg = @"Failed to connect to Facebook.";
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end
