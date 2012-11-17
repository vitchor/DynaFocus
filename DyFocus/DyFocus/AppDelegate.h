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

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    DyfocusUITabBarController *tabBarController;
    DyfocusUINavigationController *cameraNavigationController;
    DyfocusUINavigationController *friendsNavigationController;
    NSArray *permissions;
    FacebookController *friendsController;
}

- (void)openFacebookSharingSession;
- (void)openFacebookFriendsSession;

- (void)resetCameraUINavigationController;
- (void)goBackToLastController;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DyfocusUITabBarController *tabBarController;

@end
