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
#import "NotificationTableViewController.h"
#import "UIImageLoaderDyfocus.h"

@interface ProfileController ()

@end

@implementation ProfileController


@synthesize logoutButton, myPicturesButton, userPicture, notificationButton;

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
    tableController.refreshString = refresh_user_url;
    
    appDelegate.currentFriend = appDelegate.myself;
    
    
    tableController.FOFArray = appDelegate.userFofArray;
    tableController.shouldHideNavigationBar = NO;
    
    tableController.navigationItem.title = @"My Pictures";
    tableController.hidesBottomBarWhenPushed = YES;
    appDelegate.insideUserProfile = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:FALSE];
    
    [myPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    [notificationButton addTarget:self action:@selector(showNotifications) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.userNameLabel.text = appDelegate.myself.name;
    
    // Load Profile Picture
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
    [imageLoader loadPictureWithFaceId:appDelegate.myself.facebookId andImageView:userPicture andIsSmall:NO];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    [delegate logEvent:@"ProfileController.viewDidAppear"];
    
    if (delegate.unreadNotifications > 0) {
        
        NSString *badgeLabel = [NSString stringWithFormat:@"%d", delegate.unreadNotifications];
        notificationBadge = [CustomBadge customBadgeWithString:badgeLabel
                                                   withStringColor:[UIColor whiteColor]
                                                    withInsetColor:[UIColor redColor]
                                                    withBadgeFrame:YES
                                               withBadgeFrameColor:[UIColor whiteColor]
                                                         withScale:1.0
                                                       withShining:YES];
    
        
        int badgeWidth = 25; int badgeheight = 25;
        
        if (delegate.unreadNotifications > 9) {
            badgeWidth = 30;
        }
    
        [notificationBadge setFrame:CGRectMake(notificationButton.frame.origin.x + notificationButton.frame.size.width - 3*badgeWidth/5, notificationButton.frame.origin.y - 2*badgeheight/5, badgeWidth, badgeheight)];
    
        [self.view addSubview:notificationBadge];
        
    } else {
        
        if (notificationBadge) {
            [notificationBadge removeFromSuperview];
            notificationBadge = nil;
        }
        
    }
    delegate.insideUserProfile = NO;
}

-(void) showNotifications {

    NotificationTableViewController *tableController = [[NotificationTableViewController alloc] init];
    
    //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    //tableController.notifications = appDelegate.userNotifications;
    
    tableController.navigationItem.title = @"Notifications";
    
    tableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";

    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
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

- (void)logout {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate closeSession];
}

@end
