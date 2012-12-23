//
//  AppDelegate.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "DyfocusUITabBarController.h"
#import "DyfocusUINavigationController.h"

#import "FacebookController.h"
#import "ProfileController.h"

#import "LoginController.h"
#import "SplashScreenController.h"
#import "CameraView.h"

#define UPLOADING 0
#define SHARING 1
#define FRIENDS 2

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    DyfocusUITabBarController *tabBarController;
    DyfocusUINavigationController *cameraNavigationController;

    NSArray *permissions;
    FacebookController *friendsController;
    WebViewController *feedWebViewController;
    LoginController *loginController;
    SplashScreenController *splashScreenController;
    CameraView *cameraViewController;
    
    
    NSMutableDictionary *friends;
    NSMutableDictionary *dyfocusFriends;    
    NSMutableDictionary *myself;
}

extern NSString *const FBSessionStateChangedNotification;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;

- (void)openFacebookSessionWithTag:(int)tag;
- (void)loadFeedUrl:(NSString *)url;

- (void)resetCameraUINavigationController;
- (void)goBackToLastController;

- (void)invitationSentGoBackToFriends;

- (void)signin;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DyfocusUITabBarController *tabBarController;

@property (nonatomic, retain)  NSMutableDictionary *friends;
@property (nonatomic, retain)  NSMutableDictionary *dyfocusFriends;
@property (nonatomic, retain)  NSMutableDictionary *myself;


@end
