
#import "WebViewController.h"
#import "LoadView.h"


@implementation WebViewController

- (id)init {
    isFirstTime = true;
	if (self = [super init]) {
		self.title = @"dyfocus";
		self.navigationItem.hidesBackButton = NO;
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)loadUrl:(NSString *)url {
	self.wantsFullScreenLayout = YES;
	m_webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	//m_webView.scalesPageToFit = YES;
    m_webView.delegate = self;
	[m_webView setBackgroundColor:[UIColor whiteColor]];
	NSURL *nsUrl = [NSURL URLWithString:url];
	NSURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:nsUrl] autorelease];
	[m_webView loadRequest:request];
	self.view = m_webView;
	[m_webView release];
}


-(void)viewWillAppear:(BOOL)animated {
    if ([UIViewController respondsToSelector:@selector(attemptRotationToDeviceOrientation)]) {
        // this ensures that the view will be presented in the orientation of the device
        // This method is only supported on iOS 5.0.  iOS 4.3 users may get a little dizzy.
        [UIViewController attemptRotationToDeviceOrientation];
    }
    
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    if (!isFirstTime) {
        [super viewDidAppear:animated];
        UIWebView *webView = (UIWebView *)self.view;
        [webView reload];
        [webView setNeedsDisplay];
    } else {
        isFirstTime = false;
    }
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //[self showOkAlertWithMessage:@"Please check your internet connection and try again" andTitle:@"Connection Error"];
	[LoadView fadeAndRemoveFromView: self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[LoadView fadeAndRemoveFromView:self.view];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[LoadView loadViewOnView:self.view withText:@"Loading..."];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

@end
