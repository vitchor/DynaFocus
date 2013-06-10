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

@synthesize tableController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithFOFArray:(NSArray *)FOFArray andUrl:(NSString *)refreshUrl {
    
    self.tableController = [[FOFTableController alloc] init];
    self.tableController.FOFArray = FOFArray;
    self.tableController.refreshString = refreshUrl;
    self.tableController.shouldHideNavigationBar = YES;
    self.tableController.shouldHideTabBarWhenScrolling = YES;
    
    [self setNavigationBarHidden:YES];
    
    return [self initWithRootViewController:self.tableController];
}

-(id) initWithTopRatedFOFArray:(NSArray *)topRatedFOFArray andTopRatedUrl:(NSString *)refreshTopRatedUrl andTrendingFOFArray:(NSArray *)itrendingFOFArray andTrendingUrl:(NSString *)irefreshTrendingUrl{

    trendingFOFArray = itrendingFOFArray;
    refreshTrendingUrl = irefreshTrendingUrl;
    
    self.tableController = [[FOFTableController alloc] init];
    self.tableController.FOFArray = topRatedFOFArray;
    self.tableController.refreshString = refreshTopRatedUrl;
    self.tableController.shouldHideNavigationBar = NO;
    self.tableController.shouldHideNavigationBarWhenScrolling = YES;
    self.tableController.shouldHideTabBarWhenScrolling = YES;
    self.tableController.shouldShowSegmentedBar = YES;
    
    [self setNavigationBarHidden:NO];

    return [self initWithRootViewController:self.tableController];
}

- (void)viewDidLoad{
    
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    if(trendingFOFArray){
        [self loadSegmentedBar];
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetSegmentedBarIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSegmentedBar
{
    segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [NSString stringWithString:NSLocalizedString(@"Top Rated", @"")],
                                             [NSString stringWithString:NSLocalizedString(@"Trending", @"")],
                                             nil]];
    
    segmentedControl.segmentedControlStyle = 7;
    segmentedControl.tintColor = [UIColor blackColor];
    
    [segmentedControl setSelectedSegmentIndex:1];
    
    [segmentedControl addTarget:self action:@selector(switchTables)
               forControlEvents:UIControlEventValueChanged];
    
    [segmentedControl setFrame:[self.navigationBar bounds]];
    
    [self.navigationBar addSubview:segmentedControl];
    [segmentedControl setHidden:YES];
    [segmentedControl release];
}

-(void)switchTables{
    
    if(segmentedControl.selectedSegmentIndex == 0){
        [self popViewControllerAnimated:YES];
    }else{
        
        FOFTableController * trendingTableController = [[FOFTableController alloc] init];
        trendingTableController.FOFArray = trendingFOFArray;
        trendingTableController.refreshString = refreshTrendingUrl;
        trendingTableController.shouldHideNavigationBar = NO;
        trendingTableController.shouldHideNavigationBarWhenScrolling = YES;
        trendingTableController.shouldHideTabBarWhenScrolling = YES;
        trendingTableController.shouldShowSegmentedBar = YES;
        trendingTableController.navigationItem.hidesBackButton = YES;
        
        [self pushViewController:trendingTableController animated:YES];
        [trendingTableController release];
    }

}

-(void)resetSegmentedBarIndex{
    [segmentedControl setSelectedSegmentIndex:0];
}

-(void)setSegmentedControlHidden:(BOOL)hidden{
    [segmentedControl setHidden:hidden];
}

@end
