//
//  SplashScreenController.m
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "SplashScreenController.h"
#import "AppDelegate.h"

@implementation SplashScreenController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(!AD_FREE_VERSION){
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568)
            [splashImage setImage:[UIImage imageNamed:@"LaunchImage_640x1136_free.png"]];
        else
            [splashImage setImage:[UIImage imageNamed:@"LaunchImage_640x960_free.png"]];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [spinner startAnimating];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"SplashScreenController.viewDidAppear"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) dealloc {
    
    [spinner release];
    [splashImage release];
    
    [super dealloc];
}

@end
