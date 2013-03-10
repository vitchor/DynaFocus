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
    if(userName && userFacebookId){
        [LoadView loadViewOnView:tableController.view];
        tableController.FOFArray = [[[NSMutableArray alloc] init] autorelease];
        tableController.userFacebookId = (NSString *) userFacebookId;
    }else{
        tableController.FOFArray = [NSMutableArray arrayWithArray:appDelegate.friendFofArray]; // Normal procedure
        tableController.userFacebookId = (NSString *) appDelegate.currentFriend.tag;
    }
    [tableController refreshWithAction:YES];
    tableController.shouldHideNavigationBar = NO;
    
    tableController.navigationItem.title = @"Friend Pictures";
    tableController.hidesBottomBarWhenPushed = YES;
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
        [imageLoader loadProfilePicture:(NSString *)appDelegate.currentFriend.tag andProfileImage:userProfileImage];
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
