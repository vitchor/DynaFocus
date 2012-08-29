//
//  SharingController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "SharingController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SharingController ()

@end

@implementation SharingController

@synthesize facebookSwitch;

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

    NSString *share = @"Share";
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                           initWithTitle:share style:UIBarButtonItemStyleDone target:self action:@selector(share)];
	self.navigationItem.rightBarButtonItem = shareButton;
	[shareButton release];
	[share release];
    
   
    
    [facebookSwitch addTarget: self action: @selector(changedSwitchValue:) forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction) changedSwitchValue: (id) sender {
    
    UISwitch *fbSwitch = (UISwitch *)sender;
    
    [FBSession setDefaultAppID:@"417476174956036"];
    if (fbSwitch.on) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // To-do, show logged in view
        } else {
            // No, display the login page.
            [self openSession];
            
        }
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithPermissions:nil
                                   allowLoginUI:YES
                              completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}
- (void)showLoginView
{
    UIViewController *topViewController = [self.navigationController topViewController];
    UIViewController *modalViewController = [topViewController modalViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![modalViewController isKindOfClass:[SharingController class]]) {
        SharingController* loginViewController = [[SharingController alloc]
                                                      initWithNibName:@"SCLoginViewController"
                                                      bundle:nil];
        [topViewController presentModalViewController:loginViewController animated:NO];
    } else {
        SharingController* loginViewController = (SharingController*)modalViewController;
        //[loginViewController loginFailed];
    }
}


-(void)share
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
