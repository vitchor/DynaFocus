//
//  FOFTableNavigationController.m
//  DyFocus
//
//  Created by Victor on 1/27/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOFTableNavigationController.h"

@interface FOFTableNavigationController ()

@end

@implementation FOFTableNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithFOFArray: (NSArray *)FOFArray {
    
    tableController = [[FOFTableController alloc] init];
    
    tableController.FOFArray = FOFArray;
    tableController.shouldHideNavigationBar = YES;
    
    //[self pushViewController:tableController animated:NO];
    [self setNavigationBarHidden:YES];
    
    //[tableController setHidesBottomBarWhenPushed:YES];
    
    return [self initWithRootViewController:tableController];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationBar.barStyle = UIBarStyleBlack;
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
