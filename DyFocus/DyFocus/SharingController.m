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
    
    
    if (fbSwitch.on) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // To-do, show logged in view
        } else {
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
                NSLog(@"BANANA");
    switch (state)         {
        case FBSessionStateOpen:
            if (!error)         {
                // We have a valid session
                NSLog(@"User session found");
            }
            NSLog(@"Aee");
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
