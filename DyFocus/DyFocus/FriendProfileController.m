//
//  FriendProfileController.h
//  DyFocus
//
//  Created by Cássio Marcos Goulart on 24/01/13.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FriendProfileController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "FOFTableController.h"
#import "LoadView.h"
#import "UIImageLoaderDyfocus.h"
#import "JSON.h"

@interface FriendProfileController ()

@end

@implementation FriendProfileController

@synthesize viewPicturesButton, userFacebookId, userName, userProfileImage, follow, unfollow;


-(id) init {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        return [self initWithNibName:@"FriendProfileController_i5" bundle:nil];
    } else {
        return [self initWithNibName:@"FriendProfileController" bundle:nil];
    }
}

- (void) resolveUserType{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    Person *user = delegate.currentFriend;
    if(user.kind == FRIENDS_ON_APP  ||  user.kind == FRIENDS_ON_APP_AND_FB){
        //FRIEND
        [follow setEnabled:FALSE];
        follow.alpha = 0.5f;
        [unfollow setEnabled:TRUE];
        unfollow.alpha = 1.0f;
    }else if(user.kind == NOT_FRIEND){
        [unfollow setEnabled:FALSE];
        unfollow.alpha = 0.5f;
        [follow setEnabled:TRUE];
        follow.alpha = 1.0f;
    } else if(user.kind == MYSELF){
        [unfollow setEnabled:FALSE];
        unfollow.alpha = 0.5f;
        [follow setEnabled:FALSE];
        follow.alpha = 0.5f;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)followUser{
    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/follow/",dyfocus_url] autorelease];
    [self JSONfollowUnfollow:url];
}

- (void)unfollowUser{
    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/unfollow/",dyfocus_url] autorelease];
    [self JSONfollowUnfollow:url];
}

//    curl -d json='{"follower_facebook_id": 100001077656862, "feed_facebook_id":640592329}' http://localhost:8000/uploader/unfollow/
- (void)JSONfollowUnfollow:(NSString*)url{
    [LoadView loadViewOnView:self.view withText:@"Loading..."];
    
//    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/follow/",dyfocus_url] autorelease];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;

    [jsonRequestObject setObject:delegate.currentFriend.facebookId forKey:@"feed_facebook_id"];
    [jsonRequestObject setObject:delegate.myself.facebookId forKey:@"follower_facebook_id"];
    
    NSString *json = [(NSObject*)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                               NSLog(@"stringReply: %@",stringReply);
                               
                               if(!error && data) {
                                   //REMOVES, CASE IT IS A FRIEND
                                   if(delegate.currentFriend.kind == FRIENDS_ON_APP_AND_FB){
                                       delegate.currentFriend.kind = NOT_FRIEND;
                                       [delegate.dyFriendsFromFace removeObjectForKey:[NSNumber numberWithLong:[delegate.currentFriend.facebookId longLongValue]]];
//                                       [[NSNumber numberWithLong:[delegate.currentFriend.facebookId longLongValue]]]
                                   }else if(delegate.currentFriend.kind == FRIENDS_ON_APP){
                                       delegate.currentFriend.kind = NOT_FRIEND;
                                       [delegate.dyFriendsAtFace removeObjectForKey:[NSNumber numberWithLong:[delegate.currentFriend.facebookId longLongValue]]];
                                   }else if(delegate.currentFriend.kind == NOT_FRIEND){
                                       delegate.currentFriend.kind = FRIENDS_ON_APP;
                                       
                                       if (!delegate.dyFriendsAtFace) {
                                           delegate.dyFriendsAtFace = [[NSMutableDictionary alloc] init];
                                       }
                                       [delegate.dyFriendsAtFace setObject:delegate.currentFriend forKey:[NSNumber numberWithLong:[delegate.currentFriend.facebookId longLongValue]]];
                                   }
                               }
                               [LoadView fadeAndRemoveFromView:self.view];
                               [self resolveUserType];
                           }
     ];
}

-(void)JSONGetNumberOfFollows {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/how_many_follow/",dyfocus_url] autorelease];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    
    [jsonRequestObject setObject:delegate.currentFriend.facebookId forKey:@"facebook_id"];
    
    NSString *json = [(NSObject*)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                               
                               NSDictionary *jsonValues = [stringReply JSONValue];
                               
                               NSLog(@"stringReply: %@",stringReply);
                               
                               if(!error && data) {
                                   NSString *followersCount = [jsonValues valueForKey:@"followers"];
                                   NSString *followingCount = [jsonValues valueForKey:@"following"];
                                   
                                   self.followersLabel.text = [NSString stringWithFormat:@"%@", followersCount];
                                   self.followingLabel.text = [NSString stringWithFormat:@"%@", followingCount];
                               }
                           }
     ];

}

-(void) showPictures{
    FOFTableController *tableController = [[FOFTableController alloc] init];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    tableController.refreshString = refresh_user_url;
    if(appDelegate.currentFriend.kind == MYSELF  ||  [appDelegate.currentFriend.facebookId isEqualToString:appDelegate.myself.facebookId]){
        tableController.FOFArray = appDelegate.userFofArray;
        tableController.userFacebookId = (NSString *) appDelegate.myself.facebookId;
    }else if(appDelegate.currentFriend.kind == FRIENDS_ON_APP || appDelegate.currentFriend.kind == FRIENDS_ON_APP_AND_FB){
        tableController.FOFArray = [NSMutableArray arrayWithArray:appDelegate.friendFofArray]; // Normal procedure
        tableController.userFacebookId = (NSString *) appDelegate.currentFriend.facebookId;
    }else if(appDelegate.currentFriend.kind == NOT_FRIEND){
        [LoadView loadViewOnView:tableController.view];
        [tableController.loadingView setHidden:FALSE];
        [LoadView removeFromView:tableController.view];
        tableController.FOFArray = [[[NSMutableArray alloc] init] autorelease];
        tableController.userFacebookId = (NSString *) appDelegate.currentFriend.facebookId;
    }
    
    [tableController refreshWithAction:YES];
    tableController.shouldHideNavigationBar = NO;
    
    tableController.navigationItem.title = @"Friend Pictures";
    tableController.hidesBottomBarWhenPushed = YES;
    appDelegate.insideUserProfile = YES;

    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:FALSE];
    [viewPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    [follow addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
    [unfollow addTarget:self action:@selector(unfollowUser) forControlEvents:UIControlEventTouchUpInside];

    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
//    if(userName && userFacebookId){
//    self.userNameLabel.text = userName;
//    [imageLoader loadProfilePicture:userFacebookId andProfileImage:userProfileImage];
//    }else{
    self.userNameLabel.text = appDelegate.currentFriend.name;
    
    if (appDelegate.currentFriend.kind == FRIENDS_ON_APP_AND_FB || appDelegate.currentFriend.kind == FRIENDS_ON_APP) {
        NSLog(@"Followers: %@, Following: %@", appDelegate.currentFriend.followersCount, appDelegate.currentFriend.followingCount);
        self.followersLabel.text = [[NSString alloc] initWithFormat:@"%@", appDelegate.currentFriend.followersCount];
        //self.followersLabel.text = [NSString stringWithFormat:@"%@", appDelegate.currentFriend.followersCount];
        self.followingLabel.text = [[NSString alloc] initWithFormat:@"%@", appDelegate.currentFriend.followingCount];
        //self.followingLabel.text = [NSString stringWithFormat:@"%@", appDelegate.currentFriend.followingCount];
    } else {
        [self JSONGetNumberOfFollows];
    }
    //[self JSONGetNumberOfFollows];

    [imageLoader loadProfilePicture:(NSString *)appDelegate.currentFriend.facebookId andProfileImage:userProfileImage];
//    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"FriendProfileController.viewDidAppear"];
    delegate.insideUserProfile = NO;
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    [self resolveUserType];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void) clearCurrentUser{
    [self.userFacebookId release];
    self.userFacebookId = nil;
    [self.userName release];
    self.userName = nil;
}

- (void)dealloc {
    [_followingLabel release];
    [_followersLabel release];
    [super dealloc];
}
@end
