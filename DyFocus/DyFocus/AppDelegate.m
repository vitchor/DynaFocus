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
@synthesize tabBarController = _tabBarController;
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    
    // Camera Controller
    CameraView *startController = [[CameraView alloc] initWithNibName:@"CameraView" bundle:nil];
    navController = [[DyfocusUINavigationController alloc] initWithRootViewController:startController];
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
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
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
    [FBSession openActiveSessionWithPermissions:[NSArray arrayWithObject:@"publish_actions"] allowLoginUI:YES
                              completionHandler:^(FBSession *session,
                                                  FBSessionState status,
                                                  NSError *error) {
                                  // session might now be open.
                              }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"ANN?");
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
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
