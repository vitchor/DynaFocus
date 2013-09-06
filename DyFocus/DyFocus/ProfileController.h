//
//  ProfileController.h
//  DyFocus
//
//  Created by Alexandre Cordeiro on 8/30/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "Person.h"
#import "LoadView.h"
#import "CustomBadge.h"
#import "UIImageLoaderDyfocus.h"

#import "FOFTableController.h"
#import "NotificationTableViewController.h"


#define FOLLOW 0
#define UNFOLLOW 1

@interface ProfileController : UIViewController {

    int userKind;

    CustomBadge *notificationBadge;
}

@property (nonatomic, readwrite) BOOL forceHideNavigationBar;

@property (strong, nonatomic) IBOutlet UIView *logoutView;
@property (retain, nonatomic) IBOutlet UIView *followView;
@property (retain, nonatomic) IBOutlet UIView *unfollowView;
@property (strong, nonatomic) IBOutlet UIView *notificationView;
@property (strong, nonatomic) IBOutlet UIView *changeImageView;

@property (strong, nonatomic) IBOutlet UIImageView *userPicture;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *myPicturesButton;
@property (strong, nonatomic) IBOutlet UIButton *notificationButton;
@property (strong, nonatomic) IBOutlet UIButton *follow;
@property (strong, nonatomic) IBOutlet UIButton *unfollow;

@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

@property (nonatomic, retain) NSMutableArray *personFOFArray;
@property (nonatomic, retain) FOFTableController *tableController;
@property (nonatomic, retain) Person *person;

- (id)initWithUserId:(long) userId;
- (id)initWithPerson:(Person *)profilePerson personFOFArray:(NSMutableArray *)profilePersonFOFArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil person:(Person *)profilePerson personFofArray:(NSMutableArray *)profilePersonFOFArray;

- (void)showNotifications;

@end