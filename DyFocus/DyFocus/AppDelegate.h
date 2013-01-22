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
#import "FOFTableController.h"

#define UPLOADING 0
#define SHARING 1
#define FRIENDS 2

//#define dyfocus_url @"http://dyfoc.us"
#define dyfocus_url @"http://192.168.100.140:8000"

@interface FOF : NSObject {
	NSString *m_name;
	NSArray *m_frames;
	NSArray *m_comments;
	NSString *m_likes;
	NSString *m_userName;
	NSString *m_userNickname;
	NSString *m_date;
	NSString *m_userId;
    
}

@property (nonatomic, retain) NSArray *m_frames;
@property (nonatomic, retain) NSArray *m_comments;
@property (nonatomic, retain) NSString *m_name;
@property (nonatomic, retain) NSString *m_likes;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userNickname;
@property (nonatomic, retain) NSString *m_userId;
@property (nonatomic, retain) NSString *m_date;
@end


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
    NSArray *featuredFofArray;
    NSArray *userFofArray;
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

-(void) logEvent:(NSString *)event;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DyfocusUITabBarController *tabBarController;

@property (nonatomic, retain)  NSMutableDictionary *friends;
@property (nonatomic, retain)  NSMutableDictionary *dyfocusFriends;
@property (nonatomic, retain)  NSMutableDictionary *myself;
@property (nonatomic, retain)  NSArray *featuredFofArray;
@property (nonatomic, retain)  NSArray *userFofArray;




@end
