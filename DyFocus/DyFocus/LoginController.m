//
//  LoginController.m
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "LoginController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "DyfocusSettings.h"
#import "PageControlFOFViewController.h"

@interface LoginController ()

@end

@implementation LoginController

@synthesize borderView, facebookConnectButton, leftButton, rightButton, fofs, scrollView, pageControl, viewControllers;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self initializeFofs];
        //borderView.layer setCornerRadius
        //borderView.layer.masksToBounds = YES;
        
    }
    return self;
}

- (void)initializeFofs{
    fofs = [[NSMutableArray alloc] initWithCapacity:3];

    NSMutableArray *m_frames0 = [[NSMutableArray alloc] initWithCapacity:2];
    UIImage *frame = [UIImage imageNamed:@"fof_example_0_0_i5.jpg"];
    [m_frames0 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_0_1_i5.jpg"];
    [m_frames0 addObject:frame];
    [fofs addObject:m_frames0];
    
    NSMutableArray *m_frames1 = [[NSMutableArray alloc] initWithCapacity:2];
    frame = [UIImage imageNamed:@"fof_example_1_0_i5.jpg"];
    [m_frames1 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_1_1_i5.jpg"];
    [m_frames1 addObject:frame];
    [fofs addObject:m_frames1];

    NSMutableArray *m_frames2 = [[NSMutableArray alloc] initWithCapacity:2];
    frame = [UIImage imageNamed:@"fof_example_2_0_i5.jpg"];
    [m_frames2 addObject:frame];
    frame = [UIImage imageNamed:@"fof_example_2_1_i5.jpg"];
    [m_frames2 addObject:frame];
    [fofs addObject:m_frames2];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"LoginController.viewDidAppear"];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    borderView.layer.cornerRadius = 3.0;
    borderView.layer.masksToBounds = YES;
    
 
    
    [facebookConnectButton addTarget:self action:@selector(connectWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    [leftButton addTarget:self action:@selector(showsPreviousFof) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(showsNextFof) forControlEvents:UIControlEventTouchUpInside];
    

 

    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
	
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
	
    // replace the placeholder if necessary
    PageControlFOFViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[PageControlFOFViewController alloc] initWithPageNumber:page];
        controller.frames = [fofs objectAtIndex:page];
        
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void) connectWithFacebook {
    DyfocusSettings *settings = [DyfocusSettings sharedSettings];
    settings.isFirstLogin = YES;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate signin];
}

/*- (void) showsPreviousFof {
    int fofSize = [fofs count];
    fofIndex = fofIndex - 1;
    if (fofIndex < 0) {
        fofIndex = fofSize - 1;
    }
    [self refreshFrames];
    
    oldFrameIndex = 0;
    
    [self.secondImageView setImage:[self.frames objectAtIndex:0]];
    [self.firstImageView setImage:[self.frames objectAtIndex:1]];
}

- (void) showsNextFof {
    int fofSize = [fofs count];
    fofIndex = fofIndex + 1;
    if (fofIndex >= fofSize) {
        fofIndex = 0;
    }
    [self refreshFrames];
    
    oldFrameIndex = 0;
    
    [self.secondImageView setImage:[self.frames objectAtIndex:0]];
    [self.firstImageView setImage:[self.frames objectAtIndex:1]];
}*/


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}


@end
