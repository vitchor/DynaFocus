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

@synthesize tableController, trendingTableController;

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

-(id) initWithTopRatedFOFArray:(NSArray *)topRatedFOFArray andTopRatedUrl:(NSString *)refreshTopRatedUrl andTrendingFOFArray:(NSArray *)trendingFOFArray andTrendingUrl:(NSString *)irefreshTrendingUrl{

    refreshTrendingUrl = irefreshTrendingUrl;
    
    self.tableController = [[FOFTableController alloc] init];
    self.tableController.FOFArray = topRatedFOFArray;
    self.tableController.refreshString = refreshTopRatedUrl;
    self.tableController.shouldHideNavigationBar = NO;
    self.tableController.shouldHideNavigationBarWhenScrolling = YES;
    self.tableController.shouldHideTabBarWhenScrolling = YES;
    self.tableController.shouldShowSegmentedBar = YES;
    
    self.trendingTableController = [[FOFTableController alloc] init];
    
    if(trendingFOFArray)
        self.trendingTableController.FOFArray = trendingFOFArray;
    else
        self.trendingTableController.FOFArray = [NSMutableArray array];
    
    self.trendingTableController.refreshString = irefreshTrendingUrl;
    self.trendingTableController.shouldHideNavigationBar = NO;
    self.trendingTableController.shouldHideNavigationBarWhenScrolling = YES;
    self.trendingTableController.shouldHideTabBarWhenScrolling = YES;
    self.trendingTableController.shouldShowSegmentedBar = YES;
    self.trendingTableController.navigationItem.hidesBackButton = YES;

    [self setNavigationBarHidden:NO];

    isFirstTimeLoading = YES;
    
    return [self initWithRootViewController:self.tableController];
}

- (void)viewDidLoad{
    
    self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    if(refreshTrendingUrl){
        [self loadSegmentedBar];
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//-(void)viewWillAppear:(BOOL)animated {
//
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(isFirstTimeLoading){
        [self resetSegmentedBarIndex];
        isFirstTimeLoading = NO;
    }
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
        [self pushViewController:self.trendingTableController animated:YES];
    }
}

-(void)resetSegmentedBarIndex{
    [segmentedControl setSelectedSegmentIndex:0];
}

-(void)setSegmentedControlHidden:(BOOL)hidden{
    [segmentedControl setHidden:hidden];
}

-(void) enableSegmentedControl:(BOOL)enable{
    segmentedControl.enabled = enable;
}

-(void)dealloc{
    
    [tableController release];
    [trendingTableController release];
    
    [super dealloc];
}

@end
