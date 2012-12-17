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
#import "LoadView.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController, friends, myself, dyfocusFriends;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"QXSZM9GQQVY6RMQQMBQN"];
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
        
        splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController" bundle:nil];
        
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
        loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
        self.window.rootViewController  = loginController;
        
        [self.window addSubview:loginController.view];

    }
    
    
    return YES;
}

- (void)setupTabController {
    // Camera Controller
    cameraViewController = [[CameraView alloc] initWithNibName:@"CameraView" bundle:nil];
    cameraViewController.hidesBottomBarWhenPushed = YES;
    cameraNavigationController = [[DyfocusUINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.hidesBottomBarWhenPushed = YES;
    UITabBarItem *cameraTab = [[UITabBarItem alloc] initWithTitle:@"Shoot" image:[UIImage imageNamed:@"df_shoot_bw.png"] tag:3];
    [cameraNavigationController setTabBarItem:cameraTab];
    
    
    
    // Featured Controller
    WebViewController *featuredWebViewController = [[WebViewController alloc] init];
    //[featuredWebViewController loadUrl: @"http://192.168.100.108:8000/uploader/0/featured_fof/"];
    [featuredWebViewController loadUrl: @"http://dyfoc.us/uploader/0/featured_fof/"];
    
    UITabBarItem *galleryTab = [[UITabBarItem alloc] initWithTitle:@"Featured" image:[UIImage imageNamed:@"df_featured_bw.png"] tag:1];
    [featuredWebViewController setTabBarItem:galleryTab];
    
    // Feed Controller
    feedWebViewController = [[WebViewController alloc] init];

    NSString *stringUrl = [[NSString alloc] initWithFormat: @"http://dyfoc.us/uploader/%@/m_feed/0/", [self.myself objectForKey:@"id"]];

    
    [feedWebViewController loadUrl: stringUrl];
    
    [stringUrl release];
    
    //[feedWebViewController loadUrl: [[NSString alloc] initWithFormat: @"http://192.168.100.108:8000/uploader/%@/user/0/fof_name/", [[UIDevice currentDevice] uniqueIdentifier]]];
    
    
    UITabBarItem *feedTab = [[UITabBarItem alloc] initWithTitle:@"Feed" image:[UIImage imageNamed:@"df_feed_bw"] tag:2];
    [feedWebViewController setTabBarItem:feedTab];
    
    
    // Friends Controller
    friendsController = [[FacebookController alloc] init];
    friendsController.hidesBottomBarWhenPushed = NO;
    
    UITabBarItem *friendsTab = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"df_friends_bw"] tag:4];
    [friendsController setTabBarItem:friendsTab];
    
    // Profile Controller
    ProfileController *profileController = [[ProfileController alloc] initWithNibName:@"ProfileController" bundle:nil];
    UITabBarItem *profileTab = [[UITabBarItem alloc] initWithTitle:@"Me" image:[UIImage imageNamed:@"df_profile_bw"] tag:5];
    [profileController setTabBarItem:profileTab];
    
    // Configure TabBarController
    
    self.tabBarController = [[[DyfocusUITabBarController alloc] init] autorelease];
    
    
    
    NSArray* controllers = [NSArray arrayWithObjects:featuredWebViewController, feedWebViewController, cameraNavigationController, friendsController, profileController, nil];
    
    self.tabBarController.viewControllers = controllers;
    
    self.tabBarController.featuredWebController = featuredWebViewController;
    self.tabBarController.feedWebController = feedWebViewController;
    
    
    // Configure window
    
    self.window.rootViewController  = self.tabBarController;
    
    [self.window addSubview:self.tabBarController.view];
}

- (void)resetCameraUINavigationController {
    NSArray *viewControllers = cameraNavigationController.viewControllers;
    UIViewController *rootViewController = [viewControllers objectAtIndex:0];
    [cameraNavigationController setNavigationBarHidden:YES animated:YES];
    [cameraNavigationController setViewControllers:[NSArray arrayWithObject:rootViewController] animated:YES];
    
    [cameraViewController showToast:@"Upload Complete."];
    
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
                     
                     NSMutableDictionary *people = [[[NSMutableDictionary alloc] initWithCapacity:[friendsArray count]] autorelease];
                     
                     NSMutableArray *jsonFriendsDyfocusRequest = [[[NSMutableArray alloc] initWithCapacity:[friendsArray count]] autorelease];
                     
                     if ( httpCode == 200 && !error ) {
                           
                         for (NSDictionary* friend in friendsArray) {
                             
                             NSString *friendId = [friend objectForKey:@"id"];
                             NSString *friendName = [friend objectForKey:@"name"];
                             NSString *friendUsername = [friend objectForKey:@"username"];
                             
                             Person *person = [[[Person alloc] initWithId:[friendId longLongValue] andName:friendName andDetails:friendUsername andTag:friendId] autorelease];
                             
                             [people setObject:person forKey:[NSNumber numberWithLong:[friendId longLongValue]]];
                             
                             NSLog(@"I have a friend named %@ with id %@", friendName, friendId);

                             
                             //Creates json object and add to the request object
                             NSMutableDictionary *jsonFriendObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
                             
                             [jsonFriendObject setObject:friendId forKey:@"facebook_id"];
                             
                             [jsonFriendsDyfocusRequest addObject:jsonFriendObject];
                             
                         }
                         // Sets the model object friends
                         self.friends = people;
                         
                     
                     
                         // Let's parse the user information
                         NSDictionary *userResponse = [allResponses objectAtIndex:1];
                         NSMutableDictionary *user = [[userResponse objectForKey:@"body"] JSONValue];
                         
                         // Sets the model object myself
                         self.myself = user;
                         
                         NSLog(@"My name is %@ and my id is %@", [user objectForKey:@"name"], [user objectForKey:@"id"]);
                         
                         
                         
                         // Lets create the json, with all the user info, that will be used in the request
                         NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
                         
                         [jsonRequestObject setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
                         [jsonRequestObject setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];
                         [jsonRequestObject setObject:[user objectForKey:@"name"] forKey:@"name"];
                         [jsonRequestObject setObject:[user objectForKey:@"email"] forKey:@"email"];                             
                         
                         [jsonRequestObject setObject:jsonFriendsDyfocusRequest forKey:@"friends"];
                         
                         NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
                         
                         
                         // Lets create the network request
                         NSURL *webServiceUrl = [NSURL URLWithString:@"http://dyfoc.us/uploader/user_info/"];
                         
                         NSString *postString = [[NSString alloc] initWithFormat:@"json=%@", json];
                         NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:webServiceUrl];
                         [postRequest setHTTPMethod:@"POST"];
                         [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                         
                         NSURLResponse *response;
                         NSHTTPURLResponse *httpResponse;
                         NSData *dataReply;
                         NSString *stringReply;
                         
                         
                         // Lets read the response from the server
                         dataReply = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
                         stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
                         httpResponse = (NSHTTPURLResponse *)response;
                         int statusCode = [httpResponse statusCode];
                         
                         NSLog(@"JSON RESPONSE: %@",stringReply);
                         
                         //Lets parse the response to get the dyfocus friends info
                         NSMutableDictionary *friendsDictionary = [[NSMutableDictionary alloc] init];
                         
                         if (statusCode == 200) {
                             // Let's parse the response and create a NSMutableDictonary with the friends:
                             
                             if (stringReply) {
                                 NSDictionary *jsonValues = [stringReply JSONValue];
                                 
                                 if (jsonValues) {
                                     NSDictionary * jsonFriends = [jsonValues valueForKey:@"friends_list"];
                                     
                                     if (jsonFriends) {
                                         
                                         for (int i = 0; i < [jsonFriends count]; i++) {
                                             
                                             NSDictionary *jsonFriend = [jsonFriends objectAtIndex:i];
                                             NSString *friendId = [jsonFriend valueForKey:@"facebook_id"];
                                             
                                             Person *person = [people objectForKey:[NSNumber numberWithLong:[friendId longLongValue]]];
                                             
                                             [friendsDictionary setObject:person forKey:[NSNumber numberWithLong:[person.tag longLongValue]]];
                                             [people removeObjectForKey:[NSNumber numberWithLong:[person.tag longLongValue]]];
                                         }
                                         
                                        self.dyfocusFriends = friendsDictionary;
                                     
                                        //AWESOME! We have everything we need, time to continue the app flow
                                        //[LoadView fadeAndRemoveFromView:loginController.view];
                                        [splashScreenController.view removeFromSuperview];
                                         
                                         
                                        //[loginController.view removeFromSuperview];
                                
                                        [self setupTabController];
                                     
                                     }
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
    
    loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    
    [self.window addSubview:loginController.view];
}

- (void)reopenSession {
    
    permissions =  [[NSArray arrayWithObjects:
                              @"publish_actions", @"user_about_me", @"friends_about_me", @"email", nil] retain];
    
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session,
                                                                                                 FBSessionState status,
                                                                                                 NSError *error) {
        switch (status) {
            case FBSessionStateOpen:
                [self loadModel];
                
                break;
            case FBSessionStateClosed:
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
         
         
         NSDictionary *body = [[friendsResponse objectForKey:@"body"] JSONValue];
         
         NSArray* friendsArray = [body objectForKey:@"data"];
         
         NSMutableDictionary *people = [[[NSMutableDictionary alloc] initWithCapacity:[friendsArray count]] autorelease];
         
         NSMutableArray *jsonFriendsDyfocusRequest = [[[NSMutableArray alloc] initWithCapacity:[friendsArray count]] autorelease];
         
         if ( httpCode == 200 && !error ) {
             
             for (NSDictionary* friend in friendsArray) {
                 
                 NSString *friendId = [friend objectForKey:@"id"];
                 NSString *friendName = [friend objectForKey:@"name"];
                 NSString *friendUsername = [friend objectForKey:@"username"];
                 
                 Person *person = [[[Person alloc] initWithId:[friendId longLongValue] andName:friendName andDetails:friendUsername andTag:friendId] autorelease];
                 
                 [people setObject:person forKey:[NSNumber numberWithLong:[friendId longLongValue]]];
                 
                 NSLog(@"I have a friend named %@ with id %@", friendName, friendId);
                 
                 
                 //Creates json object and add to the request object
                 NSMutableDictionary *jsonFriendObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
                 
                 [jsonFriendObject setObject:friendId forKey:@"facebook_id"];
                 
                 [jsonFriendsDyfocusRequest addObject:jsonFriendObject];
                 
             }
             // Sets the model object friends
             self.friends = people;
             
             
             
             // Let's parse the user information
             NSDictionary *userResponse = [allResponses objectAtIndex:1];
             NSMutableDictionary *user = [[userResponse objectForKey:@"body"] JSONValue];
             
             // Sets the model object myself
             self.myself = user;
             
             NSLog(@"My name is %@ and my id is %@", [user objectForKey:@"name"], [user objectForKey:@"id"]);
             
             
             // Lets create the json, with all the user info, that will be used in the request
             NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
             
             [jsonRequestObject setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
             [jsonRequestObject setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];
             [jsonRequestObject setObject:[user objectForKey:@"name"] forKey:@"name"];
             [jsonRequestObject setObject:[user objectForKey:@"email"] forKey:@"email"];
             
             [jsonRequestObject setObject:jsonFriendsDyfocusRequest forKey:@"friends"];
             
             NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
             
             
             // Lets create the network request
             NSURL *webServiceUrl = [NSURL URLWithString:@"http://dyfoc.us/uploader/user_info/"];
             
             NSString *postString = [[NSString alloc] initWithFormat:@"json=%@", json];
             NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:webServiceUrl];
             [postRequest setHTTPMethod:@"POST"];
             [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
             
             NSURLResponse *response;
             NSHTTPURLResponse *httpResponse;
             NSData *dataReply;
             NSString *stringReply;
             
             
             // Lets read the response from the server
             dataReply = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
             stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
             httpResponse = (NSHTTPURLResponse *)response;
             int statusCode = [httpResponse statusCode];
             
             NSLog(@"JSON RESPONSE: %@",stringReply);
             
             //Lets parse the response to get the dyfocus friends info
             NSMutableDictionary *friendsDictionary = [[NSMutableDictionary alloc] init];
             
             if (statusCode == 200) {
                 // Let's parse the response and create a NSMutableDictonary with the friends:
                 
                 if (stringReply) {
                     NSDictionary *jsonValues = [stringReply JSONValue];
                     
                     if (jsonValues) {
                         NSDictionary * jsonFriends = [jsonValues valueForKey:@"friends_list"];
                         
                         if (jsonFriends) {
                             
                             for (int i = 0; i < [jsonFriends count]; i++) {
                                 
                                 NSDictionary *jsonFriend = [jsonFriends objectAtIndex:i];
                                 NSString *friendId = [jsonFriend valueForKey:@"facebook_id"];
                                 
                                 Person *person = [people objectForKey:[NSNumber numberWithLong:[friendId longLongValue]]];
                                 
                                 [friendsDictionary setObject:person forKey:[NSNumber numberWithLong:[person.tag longLongValue]]];
                                 [people removeObjectForKey:[NSNumber numberWithLong:[person.tag longLongValue]]];
                             }
                             
                             self.dyfocusFriends = friendsDictionary;
                             
                             //AWESOME! We have everything we need, time to continue the app flow
                             
                             [splashScreenController.view removeFromSuperview];
                             
                             [self setupTabController];
                             
                         }
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
    // this means the user switched back to this app without completing
    // a login in Safari/Facebook App
    [FBSession setDefaultAppID:@"417476174956036"];
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
        
        splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController" bundle:nil];
        
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
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

- (void) showSplashScreen {
    splashScreenController = [[SplashScreenController alloc] initWithNibName:@"SplashScreenController" bundle:nil];
    
    [self.window addSubview:splashScreenController.view];
}

- (void) showConnectionError {
    
    if(!loginController) {
        loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    }
    
    [self.window addSubview:loginController.view];
    
    if (splashScreenController) {
        [splashScreenController.view removeFromSuperview];
    }
    
    [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
    
}


@end
