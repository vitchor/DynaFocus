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
    
    // Create Start view controller.
    CameraView *startController = [[CameraView alloc] init];
    UINavigationController *startViewNavigationController = [[UINavigationController alloc] initWithRootViewController:startController];
    [startController release];
    
    GalleryView *galleryController = [[GalleryView alloc] init];
    UINavigationController *galeryViewNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryController];
    [galleryController release];
    
    // Similarly create for photos, videos and social...
    
    // Create an array of view controllers.
    NSArray* controllers = [NSArray arrayWithObjects:startViewNavigationController, galeryViewNavigationController, nil];
    
    // Create our tab bar controller.
    _tabBarController = [[[UITabBarController alloc] init] autorelease];
    
    // Set the view controllers of the tab bar controller.
    _tabBarController.viewControllers = controllers;
    
    // Release the startViewNavigationController, photosViewNavigationController, videosViewNavigationController, socialViewNavigationController...
    
    // I don't know what this does.
    
    // Add the tab bar controller to the window.
    [self.window addSubview:_tabBarController.view];
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
