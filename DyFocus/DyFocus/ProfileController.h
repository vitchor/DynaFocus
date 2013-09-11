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

#import "FOFTableController.h"

#import "Person.h"
#import "LoadView.h"
#import "CustomBadge.h"
#import "UIImageLoaderDyfocus.h"

#define FOLLOW 0
#define UNFOLLOW 1

@interface ProfileController : UIViewController {
    
    int userKind;
    BOOL forceHideNavigationBar;
    
    IBOutlet UIButton *logoutButton;
    IBOutlet UIButton *myPicturesButton;
    IBOutlet UIButton *notificationButton;
    IBOutlet UIButton *follow;
    IBOutlet UIButton *unfollow;
    
    IBOutlet UILabel *followingLabel;
    IBOutlet UILabel *followersLabel;
    IBOutlet UILabel *userNameLabel;
    
    IBOutlet UIView *followView;
    IBOutlet UIView *unfollowView;
    IBOutlet UIView *notificationView;
    IBOutlet UIView *logoutView;
    IBOutlet UIView *changeImageView;
    IBOutlet UIImageView *userPicture;
    
    CustomBadge *notificationBadge;
}

@property (nonatomic, readwrite) BOOL forceHideNavigationBar;
@property (nonatomic, retain) NSMutableArray *personFOFArray;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) FOFTableController *tableController;

- (id)initWithUserId:(long) userId;
- (id)initWithPerson:(Person *)profilePerson personFOFArray:(NSMutableArray *)profilePersonFOFArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil person:(Person *)profilePerson personFofArray:(NSMutableArray *)profilePersonFOFArray;

- (void)showNotifications;

@end