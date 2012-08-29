
#import "WebViewController.h"
#import "LoadView.h"


@implementation WebViewController

- (id)init {
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
    
    mUrl = url;
    
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

- (void)reloadUrl {
	self.wantsFullScreenLayout = YES;
	m_webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	//m_webView.scalesPageToFit = YES;
    m_webView.delegate = self;
	[m_webView setBackgroundColor:[UIColor whiteColor]];
	NSURL *nsUrl = [NSURL URLWithString:mUrl];
	NSURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:nsUrl] autorelease];
	[m_webView loadRequest:request];
	self.view = m_webView;
	[m_webView release];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//[LoadView fadeAndRemoveFromView:_app.window];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//[LoadView fadeAndRemoveFromView:_app.window];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	//[LoadView loadViewOnView:_app.window withText:@"Loading..."];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
