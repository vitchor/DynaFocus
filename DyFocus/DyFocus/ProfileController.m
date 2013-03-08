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
#import "FOFTableController.h"
#import "CustomBadge.h"

@interface ProfileController ()

@end

@implementation ProfileController


@synthesize logoutButton, myPicturesButton, notificationBadge;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    }
    return self;
}

-(void) showPictures{
    
    FOFTableController *tableController = [[FOFTableController alloc] init];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    tableController.FOFArray = appDelegate.userFofArray;
    tableController.shouldHideNavigationBar = NO;
    tableController.refreshString = refresh_user_url;
    
    tableController.navigationItem.title = @"My Pictures";
    
    tableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
//    self.userNameLabel.text = [appDelegate.myself objectForKey:@"name"];
//    self.userProfileImage.profileID = [appDelegate.myself objectForKey:@"id"];
    
    notificationBadge = [CustomBadge customBadgeWithString:@"2"
												   withStringColor:[UIColor whiteColor]
													withInsetColor:[UIColor redColor]
													withBadgeFrame:YES
											   withBadgeFrameColor:[UIColor whiteColor]
														 withScale:1.0
													   withShining:YES];
    
    [notificationBadge setFrame:CGRectMake(30, 30, 30, 30)];
    
    
    [self.view addSubview:notificationBadge];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:FALSE];
    
    [myPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    self.userNameLabel.text = [appDelegate.myself objectForKey:@"name"];
    self.userProfileImage.profileID = [appDelegate.myself objectForKey:@"id"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";

    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
}


- (void)logout {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate closeSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end
