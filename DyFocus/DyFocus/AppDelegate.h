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

#import "FOFTableNavigationController.h"
#import "UIDyfocusImage.h"

#define UPLOADING 0
#define SHARING 1
#define FRIENDS 2

#define NOTIFICATION_LIKED_FOF 0
#define NOTIFICATION_COMMENTED_FOF 1
#define NOTIFICATION_FOLLOWED_YOU 2
#define NOTIFICATION_COMMENTED_ON_COMMENTED_FOF 3

//#define dyfocus_url @"http://dyfoc.us"
//#define dyfocus_url @"http://192.168.100.140:8000"
#define dyfocus_url @"http://192.168.0.109:8000"

#define refresh_user_url @"/uploader/json_user_fof/"
#define refresh_featured_url @"/uploader/json_featured_fof/"
#define refresh_feed_url @"/uploader/json_feed/"

@interface Notification: NSObject {
    NSString *m_message;
    NSString *m_userId;
    NSString *m_notificationId;
    int m_triggerType;
    int m_triggerId;
    BOOL m_wasRead;
}

+(Notification *) notificationFromJSON: (NSDictionary *)json;

@property (nonatomic, retain) NSString *m_message;
@property (nonatomic, retain) NSString *m_userId;
@property (nonatomic, retain) NSString *m_notificationId;
@property (nonatomic, readwrite) int m_triggerType;
@property (nonatomic, readwrite) int m_triggerId;
@property (nonatomic, readwrite) BOOL m_wasRead;

@end

@interface Like: NSObject {
	NSString *m_fofId;
	NSString *m_userName;
	NSString *m_userId;
}

@property (nonatomic, retain) NSString *m_fofId;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userId;
@end

@interface Comment: NSObject {
	NSString *m_fofId;
	NSString *m_message;
	NSString *m_userName;
	NSString *m_userId;
	NSString *m_date;    
}

@property (nonatomic, retain) NSString *m_fofId;
@property (nonatomic, retain) NSString *m_message;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userId;
@property (nonatomic, retain) NSString *m_date;
@end

@interface FOF : NSObject {
	NSString *m_name;
	NSArray *m_frames;
	NSString *m_comments;
	NSString *m_likes;
	NSString *m_userName;
	NSString *m_userNickname;
	NSString *m_date;
	NSString *m_id;
    bool m_liked;
}

+(FOF *)fofFromJSON: (NSDictionary *)json;

@property (nonatomic, retain) NSArray *m_frames;
@property (nonatomic, retain) NSString *m_comments;
@property (nonatomic, retain) NSString *m_name;
@property (nonatomic, retain) NSString *m_likes;
@property (nonatomic, retain) NSString *m_userName;
@property (nonatomic, retain) NSString *m_userNickname;
@property (nonatomic, retain) NSString *m_userId;
@property (nonatomic, retain) NSString *m_date;
@property (nonatomic, retain) NSString *m_id;
@property (nonatomic, readwrite) bool m_liked;
@end


@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    DyfocusUITabBarController *tabBarController;
    DyfocusUINavigationController *cameraNavigationController;

    NSArray *permissions;
    FacebookController *friendsController;
    FOFTableNavigationController *feedViewController;
    LoginController *loginController;
    SplashScreenController *splashScreenController;
    CameraView *cameraViewController;
    
    NSMutableDictionary *friends;
    NSMutableDictionary *dyfocusFriends;    
    NSMutableDictionary *myself;
    
    NSMutableArray *featuredFofArray;
    NSMutableArray *userFofArray;
    NSMutableArray *feedFofArray;
    NSMutableArray *notificationsArray;
    
    NSMutableArray *friendFofArray;
    Person *currentFriend;
    
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

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DyfocusUITabBarController *tabBarController;

@property (nonatomic, retain)  UIImage *myPicture;
@property (nonatomic, retain)  NSMutableDictionary *friends;
@property (nonatomic, retain)  NSMutableDictionary *dyfocusFriends;
@property (nonatomic, retain)  NSMutableDictionary *myself;
@property (nonatomic, retain)  NSMutableArray *featuredFofArray;
@property (nonatomic, retain)  NSMutableArray *userFofArray;
@property (nonatomic, retain)  NSMutableArray *feedFofArray;
@property (nonatomic, retain)  NSMutableArray *friendFofArray;
@property (nonatomic, retain)  Person *currentFriend;
@property (nonatomic, retain)  NSString *deviceId;
@property (nonatomic, retain)  NSMutableArray *notificationsArray;
@property (nonatomic, readwrite) int unreadNotifications;

@end
