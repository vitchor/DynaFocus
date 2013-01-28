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

@interface FriendProfileController ()

@end

@implementation FriendProfileController


@synthesize viewPicturesButton;

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
   
}

-(void) showPictures{
    
    FOFTableController *tableController = [[FOFTableController alloc] init];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    tableController.FOFArray = appDelegate.friendFofArray;

    tableController.navigationItem.title = @"Friend Pictures";
    
    tableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    self.userNameLabel.text = appDelegate.currentFriend.name;
    self.userProfileImage.profileID = [[NSString alloc] initWithFormat: @"%@", appDelegate.currentFriend.tag];

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
