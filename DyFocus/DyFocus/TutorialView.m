//
//  TutorialView.m
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 6/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "TutorialView.h"
#import "AppDelegate.h"

@implementation TutorialView

@synthesize pageControllers;

-(void) viewDidLoad{
    
    self.navigationItem.title = @"Tutorial";
    
    shadowView.layer.cornerRadius = 3.0;
    shadowView.layer.masksToBounds = YES;
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfTutorialPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.pageControllers = controllers;
    [controllers release];
	
    // a page is the width of the scroll view
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfTutorialPages, scrollView.frame.size.height);
    scrollView.scrollsToTop = NO;
	
    pageControl.numberOfPages = kNumberOfTutorialPages;
    pageControl.currentPage = 0;
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    UITapGestureRecognizer *singleTapOnLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendSupportEmail)];
    [supportEmailLabel addGestureRecognizer:singleTapOnLabel];
    [singleTapOnLabel release];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView initialized"];
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    if (pageControl.currentPage == kGifPage) {
        if (!gifImageView.isAnimating)
            [gifImageView startAnimating];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.showTutorial"];
}

-(void) viewWillDisappear:(BOOL)animated{
    [gifImageView stopAnimating];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void) viewDidDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)loadScrollViewWithPage:(int)page {
	
    if (page < 0) return;
    if (page >= kNumberOfTutorialPages) return;
    
    // replace the placeholder if necessary
    UIView *controller = [self.pageControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        
        if (page==0)
            controller = pageController0;
        else if (page==1)
            controller = pageController1;
        else if (page==2)
            controller = pageController2;
        else if (page==3)
            controller = pageController3;
        else if (page==4)
            controller = pageController4;
        
        if (page == kGifPage)
            [self loadGifAnimation];
        
        [self.pageControllers replaceObjectAtIndex:page withObject:controller];
        
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (controller.superview == nil) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.frame = frame;
        [scrollView addSubview:controller];
    }
    
    if (page == kGifPage) {
        if (!gifImageView.isAnimating)
            [gifImageView startAnimating];
    }
}

-(void)loadGifAnimation
{
    gifImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-01"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-02"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-03"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-04"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-05"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-06"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-07"],
                                         [UIImage imageNamed:@"Tutorial Dyfocus teste1-08"],
                                         nil];
    
    gifImageView.animationDuration = fAnimationDuration;
    [gifImageView startAnimating];
}

- (void)sendSupportEmail {
    
    NSArray *supportEmail = [[[NSArray alloc] initWithObjects:@"support@dyfoc.us", nil] autorelease];
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController* mailComposeController = [[MFMailComposeViewController alloc] init];
        
        mailComposeController.mailComposeDelegate = self;
        [mailComposeController setSubject:@"User Feedback"];
        [mailComposeController setToRecipients:supportEmail];
        
        if (mailComposeController)
           [self presentViewController:mailComposeController animated:YES completion:nil];
        
        [mailComposeController release];
        
    } else {
        [self showOkAlertWithMessage:@"Configure your device email app.\nGo to: \"Settings\" -> \"Mail, Contacts, Calendars\" -> Turn ON your Mail app." andTitle:@"Error"];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent || result == MFMailComposeResultCancelled) {
        NSLog(@"It's away!");
    }
    else if(result == MFMailComposeResultSaved) {
       [self showOkAlertWithMessage:@"The draft was saved in your email box." andTitle:@"Draft Saved"];
    }
    else if(result == MFMailComposeResultFailed){
        
        [self showOkAlertWithMessage:@"There was an error sending your email. Please try again later." andTitle:@"Error"];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.nextInstruction"];
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

-(void)dealloc
{
    [supportEmailLabel release];
    
    [scrollView release];
    [shadowView release];
    [pageControl release];
    [pageControllers release];
    
    [pageController0 release];
    [pageController1 release];
    [pageController2 release];
    [pageController3 release];
    [pageController4 release];
    
    [gifImageView release];
    
    [super dealloc];
}


@end
