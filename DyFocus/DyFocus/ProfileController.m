//
//  ProfileController.m
//  DyFocus
//
//  Created by Alexandre Cordeiro on 8/30/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "ProfileController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "FOFTableController.h"
#import "CustomBadge.h"
#import "NotificationTableViewController.h"
#import "UIImageLoaderDyfocus.h"
#import "LoadView.h"
#import <MobileCoreServices/UTCoreTypes.h>

#define FOLLOW 0
#define UNFOLLOW 1


@interface ProfileController ()

@end

@implementation ProfileController

@synthesize logoutButton, myPicturesButton, userPicture, notificationButton, followingLabel, followersLabel, followView, unfollowView, follow, unfollow, notificationView, logoutView, forceHideNavigationBar, tableController, changeImageView, personFOFArray, person, userNameLabel;

- (id) initWithPerson:(Person *)profilePerson personFOFArray:(NSMutableArray *)profilePersonFOFArray {

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        return [self initWithNibName:@"ProfileController_i5" bundle:nil person:profilePerson personFofArray:profilePersonFOFArray];
    } else {
        // code for 3.5-inch screen
        return [self initWithNibName:@"ProfileController" bundle:nil person:profilePerson personFofArray:profilePersonFOFArray];
    }
    
}

- (id) initWithUserId:(long)userId {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        return [self initWithNibName:@"ProfileController_i5" bundle:nil userId:userId];
    } else {
        // code for 3.5-inch screen
        return [self initWithNibName:@"ProfileController" bundle:nil userId:userId];
    }
    
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil userId:(long)userId {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/user_id_info/", dyfocus_url] autorelease];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];

        [jsonRequestObject setObject:[NSString stringWithFormat:@"%ld", userId] forKey:@"user_id"];

        NSString *json = [(NSObject*)jsonRequestObject JSONRepresentation];

//        [LoadView loadViewOnView:self.view withText:@"Loading..."];

        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                                   NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                   
                                   NSDictionary *jsonValues = [stringReply JSONValue];
                                   
//                                   [LoadView fadeAndRemoveFromView:self.view];
                                   
                                   if(!error && data) {
                                       
                                       NSLog(@"stringReply: %@",stringReply);
                                       
                                       NSMutableDictionary * jsonPerson = [jsonValues valueForKey:@"person"];
                                       
                                       self.person =  [[[Person alloc] initWithDyfocusDic:jsonPerson] autorelease];
                                       
                                       if (userKind == MYSELF) {
                                           self.person.kind = MYSELF;
                                       }
                                       
                                       NSLog(@"PERSON NAME: %@", self.person.name);
                                       
                                       [self setUIPersonValues];
//
                                       
                                       NSDictionary * FOFJSONArray = [jsonValues valueForKey:@"person_FOF_array"];
                                       
                                       if (FOFJSONArray) {
                                           
                                           NSMutableArray *FOFArray = [NSMutableArray arrayWithCapacity:[FOFJSONArray count]];
                                           
                                           for (int i = 0; i < [FOFJSONArray count]; i++) {
                                               NSDictionary *jsonFOF = [FOFJSONArray objectAtIndex:i];
                                               
                                               FOF *fof = [[FOF fofFromJSON:jsonFOF] autorelease];
                                               
                                               if(fof.m_private){
                                                   AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                                                   if(userId  &&  userId == delegate.myself.uid){
                                                       [FOFArray addObject:fof];
                                                   }
                                               }else{
                                                   [FOFArray addObject:fof];
                                               }
                                           }
                                           
                                           self.personFOFArray = FOFArray;
                                           
                                           NSString *buttonPicturesString = [NSString stringWithFormat:@"Pictures (%i)", FOFArray.count];
                                           
                                           [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateNormal];
                                           [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateHighlighted];
                                           [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateDisabled];
                                           [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateSelected];
                                       }

                                       
                                   } else {
                                       //TODO: show error
                                   }
                                   
                               }
         ];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil person:(Person *)profilePerson personFofArray:(NSMutableArray *)profilePersonFOFArray {
    
    if (!(profilePerson.kind == MYSELF) && (!profilePersonFOFArray || [profilePersonFOFArray count] == 0)) {
        
        if (profilePerson) {
            self.person = profilePerson;
            userKind = profilePerson.kind;
            return [self initWithUserId:self.person.uid];
        } else {
            return nil;
        }
        
        
    } else {
                   
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        
        if (self) {
            self.personFOFArray = profilePersonFOFArray;
            self.person = profilePerson;
            userKind = profilePerson.kind;
        }
    
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    
    [follow addTarget:self action:@selector(followUser) forControlEvents:UIControlEventTouchUpInside];
    [unfollow addTarget:self action:@selector(unfollowUser) forControlEvents:UIControlEventTouchUpInside];
    
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (forceHideNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:FALSE];
    }
    
    [myPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    [notificationButton addTarget:self action:@selector(showNotifications) forControlEvents:UIControlEventTouchUpInside];
    

    if (self.person) {
        [self setUIPersonValues];
    }
    
    if (self.personFOFArray) {
        
        NSString *buttonPicturesString = [NSString stringWithFormat:@"Pictures (%i)", self.personFOFArray.count];
        
        [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateNormal];
        [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateHighlighted];
        [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateDisabled];
        [myPicturesButton setTitle:buttonPicturesString forState:UIControlStateSelected];
        
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    [delegate logEvent:@"ProfileController.viewDidAppear"];
    
    if (userKind == MYSELF) {
        [self updateBadgeView];
    }
    
}

-(void) showPictures {
    
    if(!self.tableController){
    
        NSLog(@"PERSON IIIIIIDDDDDDDDDDDDD: %ld", self.person.uid);
        
        self.tableController = [[FOFTableController alloc] init];
        self.tableController.refreshString = refresh_user_url;
        
        self.tableController.FOFArray = self.personFOFArray;
        self.tableController.shouldHideNavigationBar = NO;
        self.tableController.shouldHideNavigationBarWhenScrolling = YES;
        
        self.tableController.userId = self.person.uid;

        self.tableController.navigationItem.title = self.person.name;
        self.tableController.hidesBottomBarWhenPushed = YES;
    
    }
    
    [self.navigationController pushViewController:self.tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

-(void)setUIPersonValues {
    
    if (self.person.kind == MYSELF) {
        
        [notificationView setHidden:NO];
        [followView setHidden:YES];
        [unfollowView setHidden:YES];
        [logoutView setHidden:NO];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageLibrary:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        
        [userPicture addGestureRecognizer:singleTap];
        [userPicture setUserInteractionEnabled:YES];
        
        [changeImageView addGestureRecognizer:singleTap];
        [changeImageView setUserInteractionEnabled:YES];


    } else {
        [changeImageView setHidden:YES];
                
        
        [notificationView setHidden:YES];
        [logoutView setHidden:YES];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        Person *user = [delegate getUserWithId:self.person.uid];
        
        if (user) {
            [followView setHidden:YES];
            [unfollowView setHidden:NO];
        } else {
            [followView setHidden:NO];
            [unfollowView setHidden:YES];
        }
    }
    
    [self.userNameLabel setText:self.person.name];
   
    [followersLabel setText:self.person.followersCount];
    [followingLabel setText:self.person.followingCount];
    
   if (!(self.person.facebookId == (id)[NSNull null] || self.person.facebookId.length == 0)) {
        
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%d&height=%d",self.person.facebookId, (int)userPicture.frame.size.width*5, (int)userPicture.frame.size.height*5] autorelease];
     
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];

        [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {                               
                                   UIImage *image = [[[UIImage alloc] initWithData:data] autorelease];
                                   [userPicture setImage:image];
                               }                           
                           }];
    }

}

- (void)showImageLibrary:(UIGestureRecognizer *)gestureRecognizer {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

-(void)updateBadgeView {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if (delegate.unreadNotifications > 0) {
        NSString *badgeLabel = [NSString stringWithFormat:@"%d", delegate.unreadNotifications];
        notificationBadge = [CustomBadge customBadgeWithString:badgeLabel
                                               withStringColor:[UIColor whiteColor]
                                                withInsetColor:[UIColor redColor]
                                                withBadgeFrame:YES
                                           withBadgeFrameColor:[UIColor whiteColor]
                                                     withScale:1.0
                                                   withShining:YES];
        
        
        int badgeWidth = 25; int badgeheight = 25;
        
        if (delegate.unreadNotifications > 9) {
            badgeWidth = 30;
        }
        
        [notificationBadge setFrame:CGRectMake(notificationView.frame.origin.x + notificationView.frame.size.width - 3*badgeWidth/5, notificationView.frame.origin.y - 2*badgeheight/5, badgeWidth, badgeheight)];
        
        [self.view addSubview:notificationBadge];
        
    } else {
        
        if (notificationBadge) {
            [notificationBadge removeFromSuperview];
            notificationBadge = nil;
        }
        
    }
}

-(void) showNotifications {

    NotificationTableViewController *notificationTableController = [[NotificationTableViewController alloc] init];
    
    //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    //notificationTableController.notifications = appDelegate.userNotifications;
    
    notificationTableController.navigationItem.title = @"Notifications";
    
    notificationTableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:notificationTableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void)logout {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate closeSession];
}

-(void)followUser{
    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/user_follow/",dyfocus_url] autorelease];
    [self sendRequest:url type:FOLLOW];
}

- (void)unfollowUser{
    NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/user_unfollow/",dyfocus_url] autorelease];
    [self sendRequest:url type:UNFOLLOW];
}

- (void)sendRequest:(NSString*)url type:(int)requestType{
    
    [LoadView loadViewOnView:self.view withText:@"Loading..."];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    
    
    NSString *person_id = [NSString stringWithFormat:@"%ld", self.person.uid];
    NSString *my_id = [NSString stringWithFormat:@"%ld", delegate.myself.uid];

    NSLog(@"FOLLOW REQUEST: %@ to %@", person_id, my_id);

    
    [jsonRequestObject setObject:person_id forKey:@"person_id"];
    
    if (requestType == FOLLOW) {
        [jsonRequestObject setObject:my_id forKey:@"follower_id"];
    } else if (requestType == UNFOLLOW) {
        [jsonRequestObject setObject:my_id forKey:@"unfollower_id"];
    }
    
    NSString *json = [(NSObject*)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                               NSLog(@"my stringReply: %@",stringReply);
                               
                               NSDictionary *jsonValues = [stringReply JSONValue];
                               if(!error && data) {
                                   if (jsonValues) {
                                       NSString * jsonResult = [jsonValues valueForKey:@"result"];
                                       if([jsonResult hasPrefix:@"ok:"]) {
                                           
                                           if (requestType == FOLLOW) {
                                               int newFollowersValue = [followersLabel.text intValue] + 1;
                                               followersLabel.text = [NSString stringWithFormat:@"%d", newFollowersValue];

                                               self.person.followersCount = followersLabel.text;
                                               [delegate.friendsThatIFollow setObject:self.person forKey:[NSNumber numberWithLong:self.person.uid]];
                                               delegate.myself.followingCount = [NSString stringWithFormat:@"%d",[delegate.myself.followingCount intValue] + 1];
                                               
                                               [followView setHidden:YES];
                                               [unfollowView setHidden:NO];
                                           } else {
                                               
                                               int newFollowersValue = [followersLabel.text intValue] - 1;
                                               followersLabel.text = [NSString stringWithFormat:@"%d", newFollowersValue];
                                               
                                               self.person.followersCount = followersLabel.text;
                                               [delegate.friendsThatIFollow removeObjectForKey:[NSNumber numberWithLong:self.person.uid]];
                                               delegate.myself.followingCount = [NSString stringWithFormat:@"%d",[delegate.myself.followingCount intValue] - 1];
                                               
                                               [followView setHidden:NO];
                                               [unfollowView setHidden:YES];
                                           }
                                           
                                       }else if([jsonResult hasPrefix:@"error:"]){
                                           [delegate showAlertBaloon:@"Connection Error" andAlertMsg:jsonResult andAlertButton:@"Ok" andController:self];
                                       }
                                   }
                               }else{
                                   [delegate showAlertBaloon:@"Connection Error" andAlertMsg:@"Please, Try again later" andAlertButton:@"Ok" andController:self];
                               }
                               
                               [LoadView fadeAndRemoveFromView:self.view];
                           }
     ];
}

-(void)dealloc{
    [logoutButton release];
    [myPicturesButton release];
    [notificationButton release];
    [follow release];
    [unfollow release];
    
    [followingLabel release];
    [followersLabel release];
    
    [logoutView release];
    [followView release];
    [unfollowView release];
    [notificationView release];
    [changeImageView release];
    
    [userPicture release];
    [tableController release];
    
    [personFOFArray removeAllObjects];
    [personFOFArray release];
    [person release];
    
    [notificationBadge release];
    
    [super dealloc];
}


@end
