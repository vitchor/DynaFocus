//
//  AppDelegate.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraView.h"
#import "WebViewController.h"
#import "DyfocusUITabBarController.h"
#import "DyfocusUINavigationController.h"
#import "FacebookController.h"
#import "ProfileController.h"
#import "Flurry.h"
#import "SharingController.h"
#import "LoginController.h"
#import "JSON.h"
#import "Flurry.h"
#import "FOFTableNavigationController.h"
#import "NSDyfocusURLRequest.h"
#import "UIImageLoaderDyfocus.h"
#import "FilterUtil.h"

@implementation Notification

@synthesize m_message, m_userId, m_notificationId, m_wasRead, m_triggerId, m_triggerType;

+(Notification *)notificationFromJSON: (NSDictionary *)json {
    Notification *notification = [[Notification alloc] autorelease];
    
    notification.m_message = [json objectForKey:@"message"];
    notification.m_userId = [json objectForKey:@"user_facebook_id"];
    notification.m_notificationId = (NSDecimalNumber *)[json objectForKey:@"notification_id"];
    notification.m_wasRead = [[json objectForKey:@"was_read"] intValue] ==  1;
    notification.m_triggerId = [[json objectForKey:@"trigger_id"] intValue];
    notification.m_triggerType = [[json objectForKey:@"trigger_type"] intValue];
    
    return notification;
}

- (void)dealloc {
    [m_message release];
    [m_userId release];
    [m_notificationId release];
	[super dealloc];
}


@end

@implementation FOF

@synthesize m_name, m_frames, m_comments, m_likes, m_userName, m_userId, m_date, m_userNickname, m_id, m_liked;

+(FOF *)fofFromJSON: (NSDictionary *)json {
    
    FOF *fof = [FOF alloc];
    
    NSString *facebook_id = [json valueForKey:@"user_facebook_id"];
    NSString *name = [json valueForKey:@"user_name"];
    
    NSString *fofId = [json valueForKey:@"id"];
    NSString *fofName = [json valueForKey:@"fof_name"];
    
    NSString *liked = [json valueForKey:@"liked"];
    
    NSDictionary *frames = [json valueForKey:@"frames"];
    
    NSString *pubDate = [json valueForKey:@"pub_date"];
    
    NSString *comments = [json valueForKey:@"comments"];
    
    NSString *likes = [json valueForKey:@"likes"];
    
    NSMutableArray *framesData = [NSMutableArray array];
    
    for (int index = 0; index < [frames count]; index++) {
        
        NSDictionary *jsonFrame = [frames objectAtIndex:index];
        
        NSMutableDictionary *frameData = [NSMutableDictionary dictionary];
        
        [frameData setValue:[jsonFrame objectForKey:@"frame_url"] forKey:@"frame_url"];
        
        [frameData setValue:[jsonFrame objectForKey:@"frame_index"] forKey:@"frame_index"];
        
        [framesData addObject:frameData];
        
    }
    
    fof.m_id = fofId;
    fof.m_name = fofName;
    fof.m_liked = [liked isEqualToString:@"1"];
    fof.m_userName = name;
    fof.m_userId = facebook_id;
    fof.m_frames = framesData;
    fof.m_likes = likes;
    fof.m_comments = comments;
    fof.m_date = pubDate;
    
    liked = nil;
    
    return fof;
}

- (void)dealloc {
    [m_name release];
    [m_frames release];
    [m_comments release];
    [m_userName release];
    [m_date release];
    [m_userNickname release];
    [m_likes release];
    [m_userId release];
    [m_id release];
	[super dealloc];
}

@end

@implementation Like

@synthesize m_userName, m_userId, m_fofId;

- (void)dealloc {
    [m_userName release];
    [m_fofId release];
    [m_userId release];
	[super dealloc];
}

@end

@implementation Comment

@synthesize m_message, m_userName, m_userId, m_fofId, m_date;

- (void)dealloc {
    [m_message release];
    [m_userName release];
    [m_fofId release];
    [m_userId release];
    [m_date release];        
	[super dealloc];
}

@end


@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController, friendsFromFb, myself, dyFriendsFromFace, featuredFofArray, userFofArray, feedFofArray, friendFofArray, currentFriend, deviceId, notificationsArray, unreadNotifications, dyFriendsAtFace, insideUserProfile;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"QXSZM9GQQVY6RMQQMBQN"];
    
    NSDictionary *userinfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    CFShow(userinfo);
    
    if (userinfo) {
        showNotification = YES;
    } else {
        showNotification = NO;
    }
    
    // Gets info from user to know if app is starting from the notification center or not.x
    
    
    [FBProfilePictureView class];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    //[TestFlight takeOff:@"d230aea85b05dd961643635056dfa4cb_MTI4NTM3MjAxMi0wOS0wOCAxNjoxMjowMS4zOTA3MzE"];
    

    [self.window makeKeyAndVisible];
    
    
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        /* Steps:
         - show splash screen
         - open the session (this won't display any UX)
         - get the user info
         - send user info to our servers.
         - enable the app flow
         */
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            // code for 4-inch screen
            splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController_5" bundle:nil];
        } else {
            // code for 3.5-inch screen
            splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController" bundle:nil];
        }
        
        [self.window addSubview:splashScreenController.view];
        
        [self reopenSession];
        
        
    } else if (FBSession.activeSession.state == FBSessionStateOpen) {

        /* Steps:
         - show splash screen
         - get the user info
         - send user info to our servers.
         - enable the app flow         
         */
        
        [self showSplashScreen];
        
        [self loadModel];
        
        
    } else {
        
        // User needs to sign-in/log-in.
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            loginController = [[LoginController alloc] initWithNibName:@"LoginController_i5" bundle:nil];
        } else {
            loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
        }
        
        
        self.window.rootViewController  = loginController;
        
        [self.window addSubview:loginController.view];

    }
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"SUCESS");

    deviceId = [[[[[deviceToken description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                              stringByReplacingOccurrencesOfString: @">" withString: @""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""] retain];
    NSLog(deviceId);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(str);
}

- (void)setupTabController {
    // Camera Controller
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        cameraViewController = [[CameraView alloc] initWithNibName:@"CameraView_5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        cameraViewController = [[CameraView alloc] initWithNibName:@"CameraView" bundle:nil];

    }
    cameraViewController.hidesBottomBarWhenPushed = YES;
    cameraNavigationController = [[DyfocusUINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.hidesBottomBarWhenPushed = YES;
    UITabBarItem *cameraTab = [[UITabBarItem alloc] initWithTitle:@"Shoot" image:[UIImage imageNamed:@"df_shoot_bw.png"] tag:3];
    [cameraTab setFinishedSelectedImage:[UIImage imageNamed:@"df_shoot_bw.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"df_shoot_bw.png"]];
    //[cameraTab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.9686 green:0.5098 blue:0.1176 alpha:1], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [cameraNavigationController setTabBarItem:cameraTab];
    
    // Cashing profile Picture
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
    [imageLoader cashProfilePicture];
    
    
    // Featured Controller
    FOFTableNavigationController *featuredWebViewController = [[FOFTableNavigationController alloc] initWithFOFArray:self.featuredFofArray andUrl:refresh_featured_url];
    
    UITabBarItem *galleryTab = [[UITabBarItem alloc] initWithTitle:@"Featured" image:[UIImage imageNamed:@"df_featured.png"] tag:1];
    [galleryTab setFinishedSelectedImage:[UIImage imageNamed:@"df_featured_white.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"df_featured.png"]];
    [featuredWebViewController setTabBarItem:galleryTab];
    
    // Feed Controller
    feedViewController = [[FOFTableNavigationController alloc] initWithFOFArray:self.feedFofArray andUrl:refresh_feed_url];

    
    //[feedWebViewController loadUrl: [[NSString alloc] initWithFormat: @"http://192.168.100.108:8000/uploader/%@/user/0/fof_name/", [[UIDevice currentDevice] uniqueIdentifier]]];
    
    
    UITabBarItem *feedTab = [[UITabBarItem alloc] initWithTitle:@"Feed" image:[UIImage imageNamed:@"df_feed"] tag:2];
    [feedTab setFinishedSelectedImage:[UIImage imageNamed:@"df_feed_white.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"df_feed.png"]];
    [feedViewController setTabBarItem:feedTab];
    
    
    // Friends Controller
    friendsController = [[FacebookController alloc] init];
    friendsController.hidesBottomBarWhenPushed = NO;
    
    DyfocusUINavigationController *friendsNavigationController = [[DyfocusUINavigationController alloc] initWithRootViewController:friendsController];
    
    UITabBarItem *friendsTab = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"df_friends"] tag:4];
    [friendsTab setFinishedSelectedImage:[UIImage imageNamed:@"df_friends_white.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"df_friends.png"]];
    [friendsNavigationController setTabBarItem:friendsTab];
    
    
    if (screenBounds.size.height == 568) {
        // Profile Controller
        profileController = [[ProfileController alloc] initWithNibName:@"ProfileController_i5" bundle:nil];
    } else {
        profileController = [[ProfileController alloc] initWithNibName:@"ProfileController" bundle:nil];
    }
    
    DyfocusUINavigationController *profileNavigationController = [[DyfocusUINavigationController alloc] initWithRootViewController:profileController];
    //    profileController.hidesBottomBarWhenPushed = NO;
    
    profileNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    profileTab = [[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"df_profile"] tag:5];
    
    unreadNotifications = 0;
    for (Notification *notification in self.notificationsArray) {
        
        if (!notification.m_wasRead) {
            unreadNotifications = unreadNotifications + 1;
        }
    }
    
    if (unreadNotifications > 0) {
        profileTab.badgeValue = [NSString stringWithFormat:@"%d", unreadNotifications];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = unreadNotifications;    
    
    [profileTab setFinishedSelectedImage:[UIImage imageNamed:@"df_profile_white.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"df_profile.png"]];
    [profileNavigationController setTabBarItem:profileTab];
    
    // Configure TabBarController
    
    self.tabBarController = [[[DyfocusUITabBarController alloc] init] autorelease];
    [[[self tabBarController] tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbar-back-divided"]];
    [[[self tabBarController] tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"selected-black"]];
    
    
    NSArray* controllers = [NSArray arrayWithObjects:featuredWebViewController, feedViewController, cameraNavigationController, friendsNavigationController, profileNavigationController, nil];
    
    self.tabBarController.viewControllers = controllers;
    
    self.tabBarController.featuredWebController = featuredWebViewController;
    self.tabBarController.feedWebController = feedViewController;
    
    
    // Configure window
    
    self.window.rootViewController  = self.tabBarController;
    
    [self.window addSubview:self.tabBarController.view];
    
    if (showNotification) {
        [self showNotificationView];
        showNotification = NO;
    }
}

-(void)updateModelWithFofArray:(NSArray *) fofs andUrl: (NSString *)refreshString andUserId: (NSString *)userId {
    
    if ([refreshString isEqualToString:refresh_featured_url]) {
        featuredFofArray = fofs;
        
    } else if ([refreshString isEqualToString:refresh_feed_url]) {
        feedFofArray = fofs;
        
    } else if ([refreshString isEqualToString:refresh_user_url]) {
        
        if (!userId || [userId isEqualToString:self.myself.facebookId]) {
            //It's me!
            userFofArray = fofs;
        }

        
    }
    
    //[fofs release];
    
}

- (void)resetCameraUINavigationController {
    NSArray *viewControllers = cameraNavigationController.viewControllers;
    UIViewController *rootViewController = [viewControllers objectAtIndex:0];
    [cameraNavigationController setNavigationBarHidden:YES animated:YES];
    [cameraNavigationController setViewControllers:[NSArray arrayWithObject:rootViewController] animated:YES];
    
    [cameraViewController showToast:@"Upload Complete."];
}

-(void)loadFeedTab{
    NSArray *viewControllers = cameraNavigationController.viewControllers;
    UIViewController *rootViewController = [viewControllers objectAtIndex:0];
    [cameraNavigationController setNavigationBarHidden:YES animated:NO];
    [cameraNavigationController setViewControllers:[NSArray arrayWithObject:rootViewController] animated:NO];
    
    [cameraViewController showToast:@"Upload Complete."];
    
    
    [feedViewController.tableController refreshWithAction:NO];
    
    tabBarController.lastControllerIndex = 1;
    tabBarController.actualControllerIndex = 1;
    [tabBarController setSelectedIndex:1];
}

-(void)goBackToLastController {
    
    if (tabBarController.lastControllerIndex != -1) {
        [self.tabBarController setSelectedIndex:tabBarController.lastControllerIndex];
        tabBarController.selectedIndex =tabBarController.lastControllerIndex;
        [tabBarController setActualControllerIndex:tabBarController.lastControllerIndex];
        
    } else {
        [self.tabBarController setSelectedIndex:0];
        tabBarController.selectedIndex =0;
        [tabBarController setActualControllerIndex:0];
    }
    
    [self.tabBarController setSelectedIndex:tabBarController.lastControllerIndex];
    tabBarController.selectedIndex =tabBarController.lastControllerIndex;
    [tabBarController setActualControllerIndex:tabBarController.lastControllerIndex];
    
    NSLog(@"Going back to controller %d", tabBarController.lastControllerIndex);
    NSLog(@"Going back to controller %d", tabBarController.actualControllerIndex);
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {

    switch (state) {
        case FBSessionStateOpen: {
            
        }
            break;
        case FBSessionStateClosed:
            break;
        case FBSessionStateClosedLoginFailed:

            break;
            
            
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)signin {
    permissions = [NSArray arrayWithObjects:
                     @"publish_actions", @"user_about_me", @"friends_about_me", @"email", nil];
    
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
        switch (status) {
            case FBSessionStateOpen: {
                
                [self showSplashScreen];
                [loginController.view removeFromSuperview];
                
                NSString *jsonRequest1 = @"{ \"method\": \"GET\", \"relative_url\": \"me/friends?fields=name,id,username\" }";
                NSString *jsonRequest2 = @"{ \"method\": \"GET\", \"relative_url\": \"me\" }";
                NSString *jsonRequestsArray = [NSString stringWithFormat:@"[ %@, %@ ]", jsonRequest1, jsonRequest2];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:jsonRequestsArray forKey:@"batch"];
                
                
                [[FBRequest requestWithGraphPath:@"me" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:
                 ^(FBRequestConnection *connection,
                   id result,
                   NSError *error) {
                     
                     NSArray *allResponses = result;
                     
                     // Let's parse the friends information first:
                     NSDictionary *friendsResponse = [allResponses objectAtIndex:0];
                     
                     int httpCode = [[friendsResponse objectForKey:@"code"] intValue];
                     
                     
                     NSDictionary *body = [[friendsResponse objectForKey:@"body"] JSONValue];
                     
                     NSArray* friendsArray = [body objectForKey:@"data"];
                     
                     
                     // self.friends are all my friends from facebook
                     if (!self.friendsFromFb) {
                         self.friendsFromFb = [[NSMutableDictionary alloc] initWithCapacity:[friendsArray count]];
                     } else {
                         [self.friendsFromFb removeAllObjects];
                     }
                     
                     NSMutableArray *jsonFriendsDyfocusRequest = [[NSMutableArray alloc] initWithCapacity:[friendsArray count]] ;
                     
                     if ( httpCode == 200 && !error ) {
                           
                         for (NSMutableDictionary* friend in friendsArray) {
                             
                             Person *person = [[Person alloc] initWithDicAndKind:friend andKind:FRIENDS_ON_FB];
                             
                             [self.friendsFromFb setObject:person forKey:[NSNumber numberWithLong:[person.facebookId longLongValue]]];
                             
                             NSLog(@"I have a friend named %@ with id %@", person.name, person.facebookId);

                             //Creates json object and add to the request object
                             NSMutableDictionary *jsonFriendObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
                             
                             [jsonFriendObject setObject:person.facebookId forKey:@"facebook_id"];
                             
                             [jsonFriendsDyfocusRequest addObject:jsonFriendObject];   
                         }
                     
                         // Let's parse the user information
                         NSDictionary *userResponse = [allResponses objectAtIndex:1];
                         NSMutableDictionary *user = [[userResponse objectForKey:@"body"] JSONValue];
                         
                         // Sets the model object myself
                         self.myself = [[Person alloc] initWithDicAndKind:user andKind:MYSELF];
                         
                         NSLog(@"My name is %@ and my id is %@", [user objectForKey:@"name"], [user objectForKey:@"id"]);
                        
                         // Lets create the json, with all the user info, that will be used in the request
                         NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
                         
                         [jsonRequestObject setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
                         [jsonRequestObject setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];
                         [jsonRequestObject setObject:[user objectForKey:@"name"] forKey:@"name"];
                         [jsonRequestObject setObject:[user objectForKey:@"email"] forKey:@"email"];
                         [jsonRequestObject setObject:@"1" forKey:@"id_origin"];
                         
                         [jsonRequestObject setObject:jsonFriendsDyfocusRequest forKey:@"friends"];
                         
                         NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
                         
                         [jsonFriendsDyfocusRequest release];
                         
                         // Lets create the network request
                         NSURL *webServiceUrl = [NSURL URLWithString: [[[NSString alloc] initWithFormat: @"%@/uploader/login/", dyfocus_url] autorelease]];
                         
                         NSString *postString = [[[NSString alloc] initWithFormat:@"json=%@", json] autorelease];
                         NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:webServiceUrl];
                         [postRequest setHTTPMethod:@"POST"];
                         [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                         
                         NSURLResponse *response;
                         NSHTTPURLResponse *httpResponse;
                         NSData *dataReply;
                         NSString *stringReply;
                         
                         
                         // Lets read the response from the server
                         dataReply = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
                         stringReply = [(NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding] autorelease];
                         httpResponse = (NSHTTPURLResponse *)response;
                         int statusCode = [httpResponse statusCode];
                         
                         NSLog(@"JSON RESPONSE: %@",stringReply);
                        
                         
                         if (!self.dyFriendsFromFace) {
                             self.dyFriendsFromFace = [[NSMutableDictionary alloc] init];
                         } else {
                             [self.dyFriendsFromFace removeAllObjects];
                         }
                         
                         if (statusCode == 200) {
                             // Let's parse the response and create a NSMutableDictonary with the friends:
                             
                            if (stringReply) {
                                 
                                 if ([self parseServerInfo:stringReply]) {
                                 
                                     //AWESOME! We have everything we need, time to continue the app flow
                                     [splashScreenController.view removeFromSuperview];
                                 
                                     [self setupTabController];
                                 }
                                 
                             }
                             
                             
                         } else {
                             [self showConnectionError];
                             
                         }

                     
                     } else {
                         [self showConnectionError];
                     }             
                     
                 }];
           
            }
                break;
            case FBSessionStateClosed:
                break;
            case FBSessionStateClosedLoginFailed:
                [self showConnectionError];
                break;
                
            default:
                break;
        }
        
        if (error) {
            [self showConnectionError];
        }
    }];
}

- (void)closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
    //[FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    //[self.tabBarController removeFromParentViewController];
    [self.tabBarController.view removeFromSuperview];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        loginController = [[LoginController alloc] initWithNibName:@"LoginController_i5" bundle:nil];
    } else {
        loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    }
    
    [self.window addSubview:loginController.view];
}

- (void)reopenSession {
    
    permissions = [NSArray arrayWithObjects:
                              @"publish_actions", @"user_about_me", @"friends_about_me", @"email", nil];
    
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session,
                                                                                                 FBSessionState status,
                                                                                                 NSError *error) {
        switch (status) {
            case FBSessionStateOpen:
                [self loadModel];
                
                break;
            case FBSessionStateClosed:
                break;
            case FBSessionStateClosedLoginFailed:
                [self showConnectionError];
                [FBSession.activeSession closeAndClearTokenInformation];
                break;
                
            default:
                break;
        }
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:error.localizedDescription
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
        }
        
    }];
}

- (void) loadModel {
    
    NSString *jsonRequest1 = @"{ \"method\": \"GET\", \"relative_url\": \"me/friends?fields=name,id,username\" }";
    NSString *jsonRequest2 = @"{ \"method\": \"GET\", \"relative_url\": \"me\" }";
    NSString *jsonRequestsArray = [NSString stringWithFormat:@"[ %@, %@ ]", jsonRequest1, jsonRequest2];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:jsonRequestsArray forKey:@"batch"];
    
    
    [[FBRequest requestWithGraphPath:@"me" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       id result,
       NSError *error) {
         
         NSArray *allResponses = result;
         
         // Let's parse the friends information first:
         NSDictionary *friendsResponse = [allResponses objectAtIndex:0];
         
         int httpCode = [[friendsResponse objectForKey:@"code"] intValue];
         
         NSString *bodyString = [friendsResponse objectForKey:@"body"];
         
         NSDictionary *body = [bodyString JSONValue];
         
         NSArray* fbFriendsArray = [body objectForKey:@"data"];
         
         if (!self.friendsFromFb) {
             self.friendsFromFb = [[NSMutableDictionary alloc] init];
         } else {
             [self.friendsFromFb removeAllObjects];
         }
        
         NSMutableArray *jsonFbFriendsDyfocusRequest = [[[NSMutableArray alloc] initWithCapacity:[fbFriendsArray count]] autorelease];
         
         if (httpCode == 200 && !error) {
             //ITERATES OVER ALL FACEBOOK FRIENDS THAT CAME FROM REQUEST jsonFbFriendsDyfocusRequest
             for (NSMutableDictionary* facebookFriend in fbFriendsArray) {
                
                 Person *person = [[Person alloc] initWithDicAndKind:facebookFriend andKind:FRIENDS_ON_FB];
                 
                 NSNumber *key = [NSNumber numberWithLong:[person.facebookId longLongValue]];
                 
                 [self.friendsFromFb setObject:person forKey:key]; // Populates the Array of FB friends
                 
                 NSLog(@"I have a friend named %@ with id %@", person.name, person.facebookId);
                 
                 //Creates json object and add to the request object
                 NSMutableDictionary *jsonFriendObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
                 
                 [jsonFriendObject setObject:person.facebookId forKey:@"facebook_id"];
                 [jsonFbFriendsDyfocusRequest addObject:jsonFriendObject];
             }
             
             // Let's parse the user information
             NSDictionary *userResponse = [allResponses objectAtIndex:1];
             NSMutableDictionary *user = [[userResponse objectForKey:@"body"] JSONValue];
             
             // Sets the model object myself
             self.myself = [[Person alloc] initWithDicAndKind:user andKind:MYSELF];
             
             UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
             NSLog(@"My name is %@ and my id is %@", [user objectForKey:@"name"], [user objectForKey:@"id"]);
             
             // Lets create the json, with all the user info, that will be used in the request
             NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
             
             if (self.deviceId) {
                 [jsonRequestObject setObject:self.deviceId forKey:@"device_id"];
             } else {
                 [jsonRequestObject setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
             }
             
             [jsonRequestObject setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];
             [jsonRequestObject setObject:[user objectForKey:@"name"] forKey:@"name"];
             [jsonRequestObject setObject:[user objectForKey:@"email"] forKey:@"email"];
             
             [jsonRequestObject setObject:jsonFbFriendsDyfocusRequest forKey:@"friends"];
             
             NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
             
             
             // Lets create the network request
             NSURL *webServiceUrl = [NSURL URLWithString:[[[NSString alloc] initWithFormat: @"%@/uploader/login/", dyfocus_url] autorelease]];
             
             NSString *postString = [[[NSString alloc] initWithFormat:@"json=%@", json] autorelease];
             NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:webServiceUrl];
             [postRequest setHTTPMethod:@"POST"];
             [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
             
             NSURLResponse *response;
             NSHTTPURLResponse *httpResponse;
             NSData *dataReply;
             NSString *stringReply;
             
             
             // Lets read the response from the server
             dataReply = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
             stringReply = [(NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding] autorelease];
             httpResponse = (NSHTTPURLResponse *)response;
             int statusCode = [httpResponse statusCode];
             
             NSLog(@"JSON RESPONSE: %@",stringReply);
             
             //Lets parse the response to get the dyfocus friends info
             if (!self.dyFriendsFromFace) {
                 self.dyFriendsFromFace = [[NSMutableDictionary alloc] init];
             } else {
                 [self.dyFriendsFromFace removeAllObjects];
             }

             
             if (statusCode == 200) {
                 // Let's parse the response and create a NSMutableDictonary with the friends:
                 
                 
                 if (stringReply) {
     
                     if ([self parseServerInfo:stringReply]) {
                         
                         //AWESOME! We have everything we need, time to continue the app flow
                         [splashScreenController.view removeFromSuperview];
                     
                         [self setupTabController];
                     }// TODO
                     
                 }
                 
                 //[body release];
    
                 
             } else {
                 [self showConnectionError];
             }
         } else {
             [self showConnectionError];
         }
         
     }];
}

- (void)invitationSentGoBackToFriends {
    
    NSArray *controllers = [[[NSArray alloc] initWithObjects:friendsController, nil] autorelease];
    
    [friendsController.navigationController setViewControllers:controllers];
    [friendsController showFriendsWithToast:@"Finished sending invitations."];
    
    
}

-(bool)parseServerInfo:(NSString *)stringReply {
    
    NSDictionary *jsonValues = [stringReply JSONValue];
    
    if (jsonValues) {
        
        if (self.notificationsArray) {
            [self.notificationsArray removeAllObjects];
        } else {
            self.notificationsArray = [[NSMutableArray alloc] init];
        }
        
        NSDictionary * jsonNotifications = [jsonValues valueForKey:@"notification_list"];
        
        if (jsonNotifications) {
            
            for (int i = 0; i < [jsonNotifications count]; i++) {
                
                NSDictionary *jsonNotification = [jsonNotifications objectAtIndex:i];
                
                Notification *notification = [Notification notificationFromJSON:jsonNotification];
                
                [self.notificationsArray addObject:notification];
            }
        }
        
        
        NSDictionary * jsonFriends = [jsonValues valueForKey:@"friends_list"];
        NSMutableArray *justAppFriends = nil;
        if (jsonFriends) {
            for (int i = 0; i < [jsonFriends count]; i++) {
                NSDictionary *jsonFriend = [jsonFriends objectAtIndex:i];
                NSString *friendId = [jsonFriend valueForKey:@"facebook_id"];
                NSString *friendName = [jsonFriend valueForKey:@"name"];
                NSString *friendIdOrigin = [jsonFriend valueForKey:@"id_origin"];
                NSString *friendFollowers = [jsonFriend valueForKey:@"followers"];
                NSString *friendFollowing = [jsonFriend valueForKey:@"following"];
                
                // Intersection of appFriends with facebookFriends
                Person *person = [self.friendsFromFb objectForKey:[NSNumber numberWithLong:[friendId longLongValue]]];
                
                if (person) {
                    person.kind = FRIENDS_ON_APP_AND_FB;
                    person.idOrigin = friendIdOrigin;
                    person.followersCount = friendFollowers;
                    person.followingCount = friendFollowing;
                    NSLog(@"Name: %@. Followers: %@. Following: %@", person.name, person.followersCount, person.followingCount);
                    // person.since
                    [self.dyFriendsFromFace setObject:person forKey:[NSNumber numberWithLong:[person.facebookId longLongValue]]];
                    [self.friendsFromFb removeObjectForKey:[NSNumber numberWithLong:[person.facebookId longLongValue]]];
                }else{
                    //NOT MY FRIEND ON FB
                    [justAppFriends addObject:friendId];
                    Person *dyFriend = [[Person alloc] initWithIdAndKind:[friendId longLongValue] andName:friendName andUserName:@"" andfacebookId:friendId andKind:FRIENDS_ON_APP];
                    dyFriend.kind = FRIENDS_ON_APP;
                    dyFriend.idOrigin = friendIdOrigin;
                    dyFriend.followersCount = friendFollowers;
                    dyFriend.followingCount = friendFollowing;
                    NSLog(@"Name: %@. Followers: %@. Following: %@", dyFriend.name, dyFriend.followersCount, dyFriend.followingCount);
                    if (!self.dyFriendsAtFace) {
                        self.dyFriendsAtFace = [[NSMutableDictionary alloc] init];
                    } else {
                        [self.dyFriendsAtFace removeAllObjects];
                    }
                    [self.dyFriendsAtFace setObject:dyFriend forKey:[NSNumber numberWithLong:[dyFriend.facebookId longLongValue]]];
                }
            }
            
        }
        // TODO 
        NSDictionary * featuredFOFList = [jsonValues valueForKey:@"featured_fof_list"];
        
        if (featuredFOFList) {
            
            NSMutableArray *featuredFOFArray = [NSMutableArray array];
            
            for (int i = 0; i < [featuredFOFList count]; i++) {
                NSDictionary *jsonFOF = [featuredFOFList objectAtIndex:i];
                
                                
                FOF *fof = [[FOF fofFromJSON:jsonFOF] autorelease];
                
                
                [featuredFOFArray addObject:fof];
                
                //NSLog(@"Adding FOf %@",fof.m_userName);
                
            }
            NSLog(@"FEATURED FOF COUNT: %d", [featuredFOFArray count]);
            
            self.featuredFofArray = featuredFOFArray;
            
        } else {
            [self showConnectionError];
            return NO;
        }
        
        //creating array user fof list
        NSDictionary * userFOFList = [jsonValues valueForKey:@"user_fof_list"];
        
        if (userFOFList) {
            
            NSMutableArray *userFOFArray = [NSMutableArray array];
            
            for (int i = 0; i < [userFOFList count]; i++) {
                NSDictionary *jsonFOF = [userFOFList objectAtIndex:i];
                
                FOF *fof = [[FOF fofFromJSON:jsonFOF] autorelease];
                
                [userFOFArray addObject:fof];
                
                //NSLog(@"Adding FOf %@",fof.m_userName);
                
            }
            NSLog(@"USER FOF COUNT: %d", [userFOFArray count]);
            
            self.userFofArray = userFOFArray;
            
        }
        
        //creating array feed fof list
        NSDictionary * feedFOFList = [jsonValues valueForKey:@"feed_fof_list"];
        
        if (feedFOFList) {
            
            NSMutableArray *feedFOFArray = [NSMutableArray array];
            
            for (int i = 0; i < [feedFOFList count]; i++) {
                NSDictionary *jsonFOF = [feedFOFList objectAtIndex:i];
                
                FOF *fof = [[FOF fofFromJSON:jsonFOF] autorelease];
                
                [feedFOFArray addObject:fof];
                
                //NSLog(@"Adding FOf %@",fof.m_userName);
                
            }
            NSLog(@"FEED FOF COUNT: %d", [feedFOFArray count]);
            
            self.feedFofArray = feedFOFArray;
            
        }
        
        
        
    } else {
        [self showConnectionError];
        return NO;
    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    return [FBSession.activeSession handleOpenURL:url];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    

    /*
    UIImage *image = [UIImage imageNamed:@"tiger.png"];
    
    UIImage *filteredImage = [FilterUtil filterImage:image withFilterId:1];
    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil);
    
    filteredImage = [FilterUtil filterImage:image withFilterId:2];
    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil);
    
    filteredImage = [FilterUtil filterImage:image withFilterId:3];
    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil);
    
    filteredImage = [FilterUtil filterImage:image withFilterId:4];
    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil);
    
    filteredImage = [FilterUtil filterImage:image withFilterId:5];
    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil);
    
    filteredImage = [FilterUtil filterImage:image withFilterId:6];
    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil);*/
    
    
    // this means the user switched back to this app without completing
    // a login in Safari/Facebook App
    [FBSession setDefaultAppID:app_fb_id];
    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        [FBSession.activeSession close]; // so we close our session and start over
        
    } else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        /* Steps:
         - show splash screen
         - open the session (this won't display any UX)
         - get the user info
         - send user info to our servers.
         - enable the app flow
         */
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            // code for 4-inch screen
            splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController_5" bundle:nil];
        } else {
            // code for 3.5-inch screen
            splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController" bundle:nil];
        }
        
        [self.window addSubview:splashScreenController.view];
        
        [self reopenSession];
    }
    
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession closeAndClearTokenInformation];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//    return UIInterfaceOrientationMaskPortrait;
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

- (void) showSplashScreen {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController_5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController" bundle:nil];
    }
    
    [self.window addSubview:splashScreenController.view];
}

- (void) showConnectionError {
    
    if(!loginController) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            loginController = [[LoginController alloc] initWithNibName:@"LoginController_i5" bundle:nil];
        } else {
            loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
        }
    }
    
    [self.window addSubview:loginController.view];
    
    if (splashScreenController) {
        [splashScreenController.view removeFromSuperview];
    }
    
    [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
    
}

-(void) logEvent:(NSString *) event {
    

    if (self.myself) {
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[NSString alloc] initWithFormat:@"%@",self.myself.facebookId], @"User ID", // Capture author info
                         [[NSString alloc] initWithFormat:@"%f",CACurrentMediaTime()], @"Time", // Capture user status
                         nil];
        
        [Flurry logEvent:event withParameters:articleParams];
    }
}

- (void) showAlertBaloon:(NSString *) alertTitle andAlertMsg:(NSString *) alertMsg andAlertButton:(NSString *) alertButton andController:(UIViewController *) controller {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:controller cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];

    [alertTitle release];
    [alertMsg release];
    [alertButton release];
}

-(void) clearNotifications {
    
    for (Notification *notification in notificationsArray) {
        notification.m_wasRead = YES;
    }
    
    profileTab.badgeValue = nil;
    
    self.unreadNotifications = 0;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Gets called when we get a call when the app is running
    NSLog(@"lalala");
    CFShow(userInfo);
    
    if ( application.applicationState == UIApplicationStateActive ) {
        // app was already in the foreground
        int badge = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
        
        NSLog(@"BADGE? %d", badge);
        
        if (badge != 0) {
            self.unreadNotifications = badge;
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
            profileTab.badgeValue = [NSString stringWithFormat:@"%d",badge];
        }
        
    } else {
        [self showNotificationView];
    }
    

   
    

    
}

-(void)showNotificationView {
    
    tabBarController.lastControllerIndex = tabBarController.actualControllerIndex;
    tabBarController.actualControllerIndex = 4;
    [tabBarController setSelectedIndex:4];

    [profileController showNotifications];
    
    //select profile controller as tab
    // call profile controller showNotifications
    
    
}

//- (void) setCurrentFriend:(long)friendId{
//    //BUILD A NEW REQUEST THAT RECEIVES AN ID AND SET BOTH:
////    currentFriend
////    friendFOFArray
//}

@end
