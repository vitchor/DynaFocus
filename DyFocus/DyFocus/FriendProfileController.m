//
//  FriendProfileController.h
//  DyFocus
//
//  Created by Cássio Marcos Goulart on 24/01/13.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FriendProfileController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "FOFTableController.h"
#import "LoadView.h"
#import "UIImageLoaderDyfocus.h"

@interface FriendProfileController ()

@end

@implementation FriendProfileController

@synthesize viewPicturesButton, userFacebookId, userName, userProfileImage;


-(id) init {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        return [self initWithNibName:@"FriendProfileController_i5" bundle:nil];
    } else {
        return [self initWithNibName:@"FriendProfileController" bundle:nil];
    }
}

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
    if(appDelegate.currentFriend.kind == MYSELF  ||  [appDelegate.currentFriend.facebookId isEqualToString:appDelegate.myself.facebookId]){
        tableController.FOFArray = appDelegate.userFofArray;
        tableController.userFacebookId = (NSString *) appDelegate.myself.facebookId;
    }else if(appDelegate.currentFriend.kind == FRIENDS_ON_APP || appDelegate.currentFriend.kind == FRIENDS_ON_APP_AND_FB){
        tableController.FOFArray = [NSMutableArray arrayWithArray:appDelegate.friendFofArray]; // Normal procedure
        tableController.userFacebookId = (NSString *) appDelegate.currentFriend.facebookId;
    }else if(appDelegate.currentFriend.kind == NOT_FRIEND){
        [LoadView loadViewOnView:tableController.view];
        [tableController.loadingView setHidden:FALSE];
        [LoadView removeFromView:tableController.view];
        tableController.FOFArray = [[[NSMutableArray alloc] init] autorelease];
        tableController.userFacebookId = (NSString *) appDelegate.currentFriend.facebookId;
    }
    
    [tableController refreshWithAction:YES];
    tableController.shouldHideNavigationBar = NO;
    
    tableController.navigationItem.title = @"Friend Pictures";
    tableController.hidesBottomBarWhenPushed = YES;
    appDelegate.insideUserProfile = YES;

    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:FALSE];
    [viewPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];

    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
    if(userName && userFacebookId){
        self.userNameLabel.text = userName;
        [imageLoader loadProfilePicture:userFacebookId andProfileImage:userProfileImage];
    }else{
        self.userNameLabel.text = appDelegate.currentFriend.name;
        [imageLoader loadProfilePicture:(NSString *)appDelegate.currentFriend.facebookId andProfileImage:userProfileImage];
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"FriendProfileController.viewDidAppear"];
    delegate.insideUserProfile = NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void) clearCurrentUser{
    [self.userFacebookId release];
    self.userFacebookId = nil;
    [self.userName release];
    self.userName = nil;
}

@end
