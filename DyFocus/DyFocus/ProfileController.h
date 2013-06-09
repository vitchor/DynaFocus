//
//  ProfileController.h
//  DyFocus
//
//  Created by Alexandre Cordeiro on 8/30/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CustomBadge.h"
#import "Person.h"

@interface ProfileController : UIViewController {
    
    FBSession *facebook;
    NSString *userName;
    
    IBOutlet UIButton *myPicturesButton;
    IBOutlet UIButton *notificationButton;
    IBOutlet CustomBadge *notificationBadge;
    IBOutlet UIImageView *userPicture;
    
    IBOutlet UILabel *followingLabel;
    IBOutlet UILabel *followersLabel;
    
    IBOutlet UIView *followView;
    IBOutlet UIView *unfollowView;
    
    IBOutlet UIView *notificationView;
    IBOutlet UIView *logoutView;
    
    IBOutlet UIButton *follow;
    IBOutlet UIButton *unfollow;
    
    BOOL forceHideNavigationBar;
    
    Person *person;
    NSMutableArray *personFOFArray;
    
    int userKind;
}

- (void)logout;
- (void)showNotifications;


- (id)initWithPerson:(Person *)profilePerson personFOFArray:(NSMutableArray *)profilePersonFOFArray;

- (id) initWithUserId:(long) userId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil person:(Person *)profilePerson personFofArray:(NSMutableArray *)profilePersonFOFArray;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIView *dyfocusProfileView;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *myPicturesButton;
@property (strong, nonatomic) IBOutlet UIImageView *userPicture;

@property (strong, nonatomic) IBOutlet UIButton *notificationButton;
@property (strong, nonatomic) IBOutlet UIView *logoutView;
@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (retain, nonatomic) IBOutlet UIView *followView;
@property (retain, nonatomic) IBOutlet UIView *unfollowView;
@property (strong, nonatomic) IBOutlet UIButton *follow;
@property (strong, nonatomic) IBOutlet UIButton *unfollow;
@property (strong, nonatomic) IBOutlet UIView *notificationView;

@property (nonatomic, readwrite) BOOL forceHideNavigationBar;

@end