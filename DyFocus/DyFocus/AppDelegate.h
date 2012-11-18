//
//  AppDelegate.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DyfocusUITabBarController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DyfocusUINavigationController.h"
#import "SharingController.h"

#define UPLOADING 0
#define SHARING 1

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    DyfocusUITabBarController *tabBarController;
    DyfocusUINavigationController *navController;
    WebViewController *feedWebViewController;
    NSArray *permissions;
}
- (void)openSessionWithTag:(int)tag;
- (void)resetCameraUINavigationController;
- (void)goBackToLastController;
- (void)loadFeedUrl:(NSString *)url;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DyfocusUITabBarController *tabBarController;



@end
