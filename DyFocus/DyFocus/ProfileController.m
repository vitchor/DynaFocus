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

@interface ProfileController ()

@end

@implementation ProfileController


@synthesize logoutButton, myPicturesButton, userPicture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void) showPictures{
    FOFTableController *tableController = [[FOFTableController alloc] init];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    tableController.FOFArray = appDelegate.userFofArray;
    tableController.shouldHideNavigationBar = NO;
    tableController.refreshString = refresh_user_url;
    
    tableController.navigationItem.title = @"My Pictures";
    
    tableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)loadImage:(NSString*)uid {
    NSLog(@"==== STEP1: Load Image with id: %@", uid);
    
//    NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture",uid] autorelease];
    NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%i&height=%i",uid, (int)userPicture.frame.size.width, (int)userPicture.frame.size.height] autorelease];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   if(image) {
                                       [userPicture setImage:image];
                                   }
                               }
                           }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:FALSE];
    
    [myPicturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    self.userNameLabel.text = [appDelegate.myself objectForKey:@"name"];
    [self loadImage:[appDelegate.myself objectForKey:@"id"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";

    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
}


- (void)logout {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate closeSession];
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
