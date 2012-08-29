
#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *m_webView;
}

- (void)loadUrl:(NSString *)url;
@end
