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

@interface FriendProfileController ()

@end

@implementation FriendProfileController

@synthesize viewPicturesButton, userFacebookId, userName, userProfileImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:FALSE];
    [viewPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];

    if(userName && userFacebookId){
        self.userNameLabel.text = userName;// appDelegate.currentFriend.name;
        [self loadImage:userFacebookId];
//        self.userProfileImage.profileID = [NSString stringWithFormat: @"%@", userFacebookId];
    }else{
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        self.userNameLabel.text = appDelegate.currentFriend.name;
        [self loadImage: (NSString *)appDelegate.currentFriend.tag];
//        self.userProfileImage.profileID = [NSString stringWithFormat: @"%@", appDelegate.currentFriend.tag];
    }
}

- (void)loadImage:(NSString*)uid {    
    //    NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture",uid] autorelease];
    NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%i&height=%i",uid, (int)userProfileImage.frame.size.width, (int)userProfileImage.frame.size.height] autorelease];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   if(image) {
                                       [userProfileImage setImage:image];
                                   }
                               }
                           }];
}

-(void) showPictures{
    FOFTableController *tableController = [[FOFTableController alloc] init];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    //[LoadView loadViewOnView:tableController.view withText:@"Loading..."];
    tableController.refreshString = refresh_user_url;
    
    if(userName && userFacebookId){
        tableController.FOFArray = [NSMutableArray arrayWithArray:appDelegate.featuredFofArray]; // This IS a gambiarra! But works just fine =)
        tableController.userFacebookId = (NSString *) userFacebookId;
    }else{
        tableController.FOFArray = [NSMutableArray arrayWithArray:appDelegate.friendFofArray]; // Normal procedure
        tableController.userFacebookId = (NSString *) appDelegate.currentFriend.tag;
    }
    
    [tableController refreshWithAction:YES];
    
    tableController.shouldHideNavigationBar = NO;
    tableController.navigationItem.title = @"Friend Pictures";
    tableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
}

- (void) clearCurrentUser{
    [self.userFacebookId release];
    self.userFacebookId = nil;
    [self.userName release];
    self.userName = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
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

@end
