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
    
    [self.navigationItem setRightBarButtonItem:nil];
    
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
    
    UITapGestureRecognizer *singleTapOnEmailLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendSupportEmail)];
    [supportEmailLabel addGestureRecognizer:singleTapOnEmailLabel];
    [singleTapOnEmailLabel release];
    
    UITapGestureRecognizer *singleTapOnWebSiteLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebSite)];
    [webSiteLabel addGestureRecognizer:singleTapOnWebSiteLabel];
    [singleTapOnWebSiteLabel release];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView initialized"];
    
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.numberOfLines = 0;
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    pageControl.currentPage = 0;
    
    CGRect frame = scrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
}

-(void) viewDidAppear:(BOOL)animated{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.showTutorial"];
}

-(void) viewWillDisappear:(BOOL)animated{
    [gifImageView stopAnimating];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
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
                                        [UIImage imageNamed:@"secPage_gif-one.gif"],
                                        [UIImage imageNamed:@"secPage_gif-two.gif"],
                                        [UIImage imageNamed:@"secPage_gif-three.gif"],
                                        [UIImage imageNamed:@"secPage_gif-four.gif"],
                                        [UIImage imageNamed:@"secPage_gif-five.gif"],
                                        [UIImage imageNamed:@"secPage_gif-six.gif"],
                                        [UIImage imageNamed:@"secPage_gif-seven.gif"],
                                        [UIImage imageNamed:@"secPage_gif-eight.gif"],
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

-(void)openWebSite
{
    NSURL *url = [NSURL URLWithString:dyfocus_url];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void)loadDoneButton
{
    NSString *doneString = @"Done";
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:doneString style:UIBarButtonItemStylePlain target:self action:@selector(tutorialDone)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	[doneString release];
}

-(void)tutorialDone
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    if(page==kNumberOfTutorialPages-1)
        [self loadDoneButton];
    else
        [self.navigationItem setRightBarButtonItem:nil];
}

-(void)dealloc
{
    [supportEmailLabel release];
    [webSiteLabel release];
    
    [scrollView release];
    [shadowView release];
    [pageControl release];
    [pageControllers release];
    
    [pageController0 release];
    [pageController1 release];
    [pageController2 release];
    [pageController3 release];
    
    [gifImageView release];
    
    [super dealloc];
}


@end
