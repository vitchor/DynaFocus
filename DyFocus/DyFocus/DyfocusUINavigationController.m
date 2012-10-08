//
//  DyfocusUINavigationController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "DyfocusUINavigationController.h"

@interface DyfocusUINavigationController ()

@end

@implementation DyfocusUINavigationController

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
    
    
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
