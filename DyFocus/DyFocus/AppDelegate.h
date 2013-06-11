//
//  AppDelegate.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//


// MODEL
#import "Comment.h"
#import "FOF.h"
#import "Like.h"
#import "Notification.h"
#import "Person.h"

#import "Settings.h"

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

// Overriden system classes
#import "DyfocusUITabBarController.h"
#import "DyfocusUINavigationController.h"
#import "UIDyfocusImage.h"

// Controllers
#import "FacebookController.h"
#import "ProfileController.h"
#import "LoginController.h"
#import "SplashScreenController.h"
#import "CameraView.h"
#import "FOFTableController.h"
#import "FOFTableNavigationController.h"


#define UPLOADING 0
#define SHARING 1
#define FRIENDS 2

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    DyfocusUITabBarController *tabBarController;
    DyfocusUINavigationController *cameraNavigationController;

    NSArray *permissions;
    FacebookController *friendsController;
    
    FOFTableNavigationController *feedViewController;
    FOFTableNavigationController *featuredViewController;
    LoginController *loginController;
    SplashScreenController *splashScreenController;
    CameraView *cameraViewController;
    
    NSMutableDictionary *friendsFromFb;         // Friends only in facebook, not the app
    NSMutableDictionary *friendsThatIFollow;       // Dyfocus friends that AREN'T   FB friends but we get their data from FB
    Person *myself;                             // My data
    
    NSMutableArray *userFofArray;
    NSMutableArray *featuredFofArray;
    NSMutableArray *feedFofArray;
    NSMutableArray *trendingFofArray;
    NSMutableArray *notificationsArray;
    
    NSString *deviceId;
    
    int unreadNotifications;
    
    UITabBarItem *profileTab;
    
    ProfileController *profileController;
    
    bool showNotification;
}

extern NSString *const FBSessionStateChangedNotification;

- (void)updateModelWithFofArray:(NSArray *) fofs andUrl: (NSString *)refreshString andUserId: (NSString *)userId;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;

- (void)openFacebookSessionWithTag:(int)tag;
- (void)loadFeedUrl:(NSString *)url;

- (void)resetCameraUINavigationController;
- (void)loadFeedTab;
- (void) showAlertBaloon:(NSString *) alertTitle andAlertMsg:(NSString *) alertMsg andAlertButton:(NSString *) alertButton andController:(UIViewController *) delegate;
- (void)goBackToLastController;

- (void)invitationSentGoBackToFriends;

- (void)signin;

-(void) logEvent:(NSString *)event;

-(void) clearNotifications;

-(void)parseSignupRequest: (NSDictionary *) jsonValues;

-(NSMutableArray *) FOFsFromUser: (long)userId;
-(Person *) getUserWithId: (long long)userId;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DyfocusUITabBarController *tabBarController;

@property (nonatomic, retain)  UIImage *myPicture;
@property (nonatomic, retain)  NSMutableDictionary *friendsFromFb;
@property (nonatomic, retain)  NSMutableDictionary *friendsThatIFollow;
@property (nonatomic, retain)  Person *myself;
@property (nonatomic, retain)  NSMutableArray *userFofArray;
@property (nonatomic, retain)  NSMutableArray *featuredFofArray;
@property (nonatomic, retain)  NSMutableArray *feedFofArray;
@property (nonatomic, retain)  NSMutableArray *trendingFofArray;
@property (nonatomic, retain)  NSMutableArray *notificationsArray;
@property (nonatomic, retain)  NSString *deviceId;

@property (nonatomic, readwrite) int unreadNotifications;


@end
