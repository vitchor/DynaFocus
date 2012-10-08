//
//  AppDelegate.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraView.h"
#import "GalleryView.h"
#import "WebViewController.h"
#import "DyfocusUITabBarController.h"
#import "DyfocusUINavigationController.h"
#import "FriendsController.h"
#import "ProfileController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    //[TestFlight takeOff:@"d230aea85b05dd961643635056dfa4cb_MTI4NTM3MjAxMi0wOS0wOCAxNjoxMjowMS4zOTA3MzE"];

    
    // Camera Controller
    CameraView *startController = [[CameraView alloc] initWithNibName:@"CameraView" bundle:nil];
    startController.hidesBottomBarWhenPushed = YES;
    navController = [[DyfocusUINavigationController alloc] initWithRootViewController:startController];
    navController.hidesBottomBarWhenPushed = YES;
    UITabBarItem *cameraTab = [[UITabBarItem alloc] initWithTitle:@"Shoot" image:[UIImage imageNamed:@"df_shoot_bw.png"] tag:3];
    [navController setTabBarItem:cameraTab];
    [startController release];
    
    
    // Featured Controller
    WebViewController *featuredWebViewController = [[WebViewController alloc] init];
    //[featuredWebViewController loadUrl: @"http://192.168.100.108:8000/uploader/0/featured_fof/"];
    [featuredWebViewController loadUrl: @"http://dyfoc.us/uploader/0/featured_fof/"];
    
    UITabBarItem *galleryTab = [[UITabBarItem alloc] initWithTitle:@"Featured" image:[UIImage imageNamed:@"df_featured_bw.png"] tag:1];
    [featuredWebViewController setTabBarItem:galleryTab];
    
    // Feed Controller
    WebViewController *feedWebViewController = [[WebViewController alloc] init];
    
    NSString *stringUrl = [[NSString alloc] initWithFormat: @"http://dyfoc.us/uploader/%@/user/0/fof_name/", [[UIDevice currentDevice] uniqueIdentifier]];
    
    [feedWebViewController loadUrl: stringUrl];
    
    [stringUrl release];
    
    //[feedWebViewController loadUrl: [[NSString alloc] initWithFormat: @"http://192.168.100.108:8000/uploader/%@/user/0/fof_name/", [[UIDevice currentDevice] uniqueIdentifier]]];
    
  
    UITabBarItem *feedTab = [[UITabBarItem alloc] initWithTitle:@"Feed" image:[UIImage imageNamed:@"df_feed_bw"] tag:2];
    [feedWebViewController setTabBarItem:feedTab];

    
    // Friends Controller
    FriendsController *friendsController = [[FriendsController alloc] initWithNibName:@"FriendsController" bundle:nil];
    UITabBarItem *friendsTab = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"df_friends_bw"] tag:4];
    [friendsController setTabBarItem:friendsTab];
        
    // Profile Controller
    ProfileController *profileController = [[ProfileController alloc] initWithNibName:@"ProfileController" bundle:nil];
    UITabBarItem *profileTab = [[UITabBarItem alloc] initWithTitle:@"Me" image:[UIImage imageNamed:@"df_profile_bw"] tag:5];
    [profileController setTabBarItem:profileTab];
    
    // Configure TabBarController
    
    self.tabBarController = [[[DyfocusUITabBarController alloc] init] autorelease];
    
    
    
    NSArray* controllers = [NSArray arrayWithObjects:featuredWebViewController, feedWebViewController, navController, friendsController, profileController, nil];
    
    self.tabBarController.viewControllers = controllers;
    
    self.tabBarController.featuredWebController = featuredWebViewController;
    self.tabBarController.feedWebController = feedWebViewController;
    

    // Configure window
    
    self.window.rootViewController  = self.tabBarController;
    
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    NSLog(@"aaa");
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self reopenSession];
    }
    
    
    return YES;
}

- (void)resetCameraUINavigationController {
    NSArray *viewControllers = navController.viewControllers;
    UIViewController *rootViewController = [viewControllers objectAtIndex:0];
    [navController setNavigationBarHidden:YES animated:YES];
    [navController setViewControllers:[NSArray arrayWithObject:rootViewController] animated:YES];
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
                      error:(NSError *)error
{
    NSLog(@"as");
    switch (state) {
        case FBSessionStateOpen: {
            
            
            /*UIViewController *topViewController =
            [navController topViewController];
            if ([[topViewController modalViewController]
                 isKindOfClass:[SCLoginViewController class]]) {
                [topViewController dismissModalViewControllerAnimated:YES];
            }*/
            NSLog(@"Sweet, let it flow..");
            
            
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            /*
            
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
             */
            NSLog(@"Error message at sharing controller");
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

- (void)openSession {
    
    permissions =  [[NSArray arrayWithObjects:
                     @"publish_actions", @"user_about_me", @"friends_about_me", @"email", nil] retain];
    
     SharingController *sharingController = (SharingController *)[navController topViewController];
    
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
          switch (status) {
              case FBSessionStateOpen: {
                 
                  [sharingController requestUserInfo:session];
                  NSLog(@"Sweet, let it flow..");
              }
                  break;
              case FBSessionStateClosed:
              case FBSessionStateClosedLoginFailed:
                  [sharingController facebookError];
                  [FBSession.activeSession closeAndClearTokenInformation];
                  break;
                  
              default:
                  break;
          }
          
          if (error) {
              [sharingController facebookError];
          }
          [permissions release];        
      }];
    
}

- (void)reopenSession {
    
    permissions =  [[NSArray arrayWithObjects:
                              @"publish_actions", @"user_about_me", @"friends_about_me", @"email", nil] retain];
    
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session,
                                                                                                 FBSessionState status,
                                                                                                 NSError *error) {
        switch (status) {
            case FBSessionStateOpen: {
                NSLog(@"Sweet, let it flow..");
            }
                break;
            case FBSessionStateClosed:
            case FBSessionStateClosedLoginFailed:
                NSLog(@"Error message at sharing controller");
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
        [permissions release];
    }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
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
    // this means the user switched back to this app without completing
    // a login in Safari/Facebook App
    [FBSession setDefaultAppID:@"417476174956036"];
    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        [FBSession.activeSession close]; // so we close our session and start over
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
}


@end
