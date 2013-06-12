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
#import "JSON.h"
#import "LoadView.h"

@interface LoginController ()

@end

@implementation LoginController


// SIGN UP OUTLETS
@synthesize signupView, signupFullNameTextField, signupFullNameTextFieldErrorLabel, signupEmailTextField, signupEmailTextFieldErrorLabel, signupPasswordTextField, signupPasswordTextFieldErrorLabel, signupCancelButton, showSignupButton;

// LOGIN VIEW OUTLETS
@synthesize loginView, loginEmailTextField, loginEmailTextFieldErrorLabel, loginPasswordTextField, loginPasswordTextFieldErrorLabel, loginCancelButton, showLoginButton;


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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {

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
        
    } else {
        
        UIImage *frame = [UIImage imageNamed:@"fof_example_0_0.jpg"];
        [m_frames0 addObject:frame];
        frame = [UIImage imageNamed:@"fof_example_0_1.jpg"];
        [m_frames0 addObject:frame];
        [fofs addObject:m_frames0];
        
        NSMutableArray *m_frames1 = [[NSMutableArray alloc] initWithCapacity:2];
        frame = [UIImage imageNamed:@"fof_example_1_0.jpg"];
        [m_frames1 addObject:frame];
        frame = [UIImage imageNamed:@"fof_example_1_1.jpg"];
        [m_frames1 addObject:frame];
        [fofs addObject:m_frames1];
        
        NSMutableArray *m_frames2 = [[NSMutableArray alloc] initWithCapacity:2];
        frame = [UIImage imageNamed:@"fof_example_2_0.jpg"];
        [m_frames2 addObject:frame];
        frame = [UIImage imageNamed:@"fof_example_2_1.jpg"];
        [m_frames2 addObject:frame];
        [fofs addObject:m_frames2];
    }
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
    //[leftButton addTarget:self action:@selector(showsPreviousFof) forControlEvents:UIControlEventTouchUpInside];
    //[rightButton addTarget:self action:@selector(showsNextFof) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIView *textField in [signupView subviews]) {
        if ([textField conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                
                if (textField == signupEmailTextField) { 
                    [(UITextField *)textField setKeyboardType:UIKeyboardTypeEmailAddress];
                } else {
                    [(UITextField *)textField setKeyboardType:UIKeyboardTypeDefault];
                }
            
                [(UITextField *)textField setReturnKeyType:UIReturnKeyGo];
                [(UITextField *)textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) { 
                // ignore exception
            }
        }
    }
    
    for (UIView *textField in [loginView subviews]) {
        if ([textField conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                
                if (textField == loginEmailTextField) {
                    [(UITextField *)textField setKeyboardType:UIKeyboardTypeEmailAddress];
                } else {
                    [(UITextField *)textField setKeyboardType:UIKeyboardTypeDefault];
                }
                
                [(UITextField *)textField setReturnKeyType:UIReturnKeyGo];
                [(UITextField *)textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) {  
                // ignore exception
            }
        }
    }
    
    [showLoginButton addTarget:self action:@selector(showLogin) forControlEvents:UIControlEventTouchUpInside];
    [loginCancelButton addTarget:self action:@selector(hideLogin) forControlEvents:UIControlEventTouchUpInside];
 
    [signupCancelButton addTarget:self action:@selector(hideSignup) forControlEvents:UIControlEventTouchUpInside];
    
    [showSignupButton addTarget:self action:@selector(showSignup) forControlEvents:UIControlEventTouchUpInside];
    
    [showSignupButton addTarget:self action:@selector(showSignup) forControlEvents:UIControlEventTouchUpInside];
    
    signupEmailTextField.delegate = self;
    signupFullNameTextField.delegate = self;
    signupPasswordTextField.delegate = self;
    
    loginEmailTextField.delegate = self;
    loginPasswordTextField.delegate = self;
    
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == loginPasswordTextField || textField == loginEmailTextField) {
        [self sendLoginRequest];

    } else {
        [self sendSignupRequest];
        
    }
    
    return YES;
}

-(void) sendLoginRequest {
    
    if ([loginEmailTextField.text isEqualToString:@""] || ![self isValidEmail:loginEmailTextField.text]) {
        [loginEmailTextFieldErrorLabel setText:@"Please enter a valid email:"];
        [loginEmailTextFieldErrorLabel setHidden:NO];
        
    } else if ([loginPasswordTextField.text isEqualToString:@""]) {
        [loginPasswordTextFieldErrorLabel setText:@"Please enter your password:"];
        [loginEmailTextFieldErrorLabel setHidden:YES];
        [loginPasswordTextFieldErrorLabel setHidden:NO];
        
    } else {
        
        [LoadView loadViewOnView:self.view withText:@"Loading..."];
        
        NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/login_user/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        if (delegate.deviceId) {
            [jsonRequestObject setObject:delegate.deviceId forKey:@"device_id"];
        } else {
            [jsonRequestObject setObject:@"null" forKey:@"device_id"];
        }
        
        [jsonRequestObject setObject:loginEmailTextField.text forKey:@"user_email"];
        [jsonRequestObject setObject:loginPasswordTextField.text forKey:@"user_password"];
        
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"SENDING");
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   [LoadView fadeAndRemoveFromView:self.view];
                                   
                                   if(!error && data) {
                                       
                                       NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                       
                                       NSLog(@"stringReply: %@",stringReply);
                                       
                                       NSDictionary *jsonValues = [stringReply JSONValue];
                                       
                                       NSString *error = [jsonValues valueForKey:@"error"];
                                       
                                       if (!error) {
                                           
                                           [self hideKeyboard];
                                           [self hideSignup];
                                           [delegate parseSignupRequest:jsonValues];
                                           
                                           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                           [userDefaults setObject:loginEmailTextField.text forKey:@"savedEmail"];
                                           [userDefaults setObject:loginPasswordTextField.text forKey:@"savedPassword"];
                                           [userDefaults synchronize];
                                           
                                       } else {
                                           [loginEmailTextFieldErrorLabel setText:error];
                                           [loginEmailTextFieldErrorLabel setHidden:NO];
                                           
                                       }
                                   } else {
                                       [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
                                   }
                                   
                                   NSLog(@"ERROR");
                               }
         ];
        
    }
}

-(void) sendSignupRequest {
    
    if ([signupFullNameTextField.text isEqualToString:@""]) {
        [signupFullNameTextFieldErrorLabel setHidden:NO];
        
    } else if ([signupEmailTextField.text isEqualToString:@""] || ![self isValidEmail:signupEmailTextField.text]) {
        [signupEmailTextFieldErrorLabel setText:@"Please enter a valid email:"];
        [signupFullNameTextFieldErrorLabel setHidden:YES];
        [signupEmailTextFieldErrorLabel setHidden:NO];
        
    }  else if ([signupPasswordTextField.text isEqualToString:@""] || [signupPasswordTextField.text length] < 6) {
        [signupFullNameTextFieldErrorLabel setHidden:YES];
        [signupEmailTextFieldErrorLabel setHidden:YES];
        [signupPasswordTextFieldErrorLabel setHidden:NO];
        
    } else {
        [signupFullNameTextFieldErrorLabel setHidden:YES];
        [signupEmailTextFieldErrorLabel setHidden:YES];
        [signupPasswordTextFieldErrorLabel setHidden:YES];
        

        [LoadView loadViewOnView:self.view withText:@"Loading..."];
        
        NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/signup/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        if (delegate.deviceId) {
            [jsonRequestObject setObject:delegate.deviceId forKey:@"device_id"];
        } else {
            [jsonRequestObject setObject:@"null" forKey:@"device_id"];
        }
        
        [jsonRequestObject setObject:signupFullNameTextField.text forKey:@"user_name"];
        [jsonRequestObject setObject:signupEmailTextField.text forKey:@"user_email"];
        [jsonRequestObject setObject:signupPasswordTextField.text forKey:@"user_password"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"SENDING");
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   [LoadView fadeAndRemoveFromView:self.view];
                                   
                                   if(!error && data) {
                                       
                                       NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

                                       NSLog(@"stringReply: %@",stringReply);
                                   
                                       NSDictionary *jsonValues = [stringReply JSONValue];
                                       
                                       NSString *error = [jsonValues valueForKey:@"error"];
                                       
                                       if (!error) {
                                           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                           [userDefaults setObject:signupEmailTextField.text forKey:@"savedEmail"];
                                           [userDefaults setObject:signupPasswordTextField.text forKey:@"savedPassword"];
                                           [userDefaults synchronize];

                                           [self hideKeyboard];
                                           [self hideSignup];
                                           [delegate parseSignupRequest:jsonValues];
                                           
                                       } else {
                                           [signupEmailTextFieldErrorLabel setText:error];
                                           [signupEmailTextFieldErrorLabel setHidden:NO];
                                           
                                       }
                                   } else {
                                       [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
                                   }
                                   
                                   NSLog(@"ERROR");
                               }
         ];

    }
}

-(void) showLogin {
    [UIView animateWithDuration:0.25 animations:^{loginView.alpha = 1.0;}];
    [loginEmailTextField becomeFirstResponder];
}

-(void) hideLogin {
    [UIView animateWithDuration:0.25 animations:^{loginView.alpha = 0.0;}];
    [self hideKeyboard];
}

-(void) showSignup {
    [signupFullNameTextField becomeFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{signupView.alpha = 1.0;}];

}

- (void) hideSignup {
    [UIView animateWithDuration:0.25 animations:^{signupView.alpha = 0.0;}];
    [self hideKeyboard];
}


-(void)hideKeyboard {
    [loginPasswordTextField resignFirstResponder];
    [loginEmailTextField resignFirstResponder];
    
    [signupPasswordTextField resignFirstResponder];
    [signupFullNameTextField resignFirstResponder];
    [signupEmailTextField resignFirstResponder];
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

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

@end
