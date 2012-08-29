
#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *m_webView;
    NSString *mUrl;
}

- (void)loadUrl:(NSString *)url;
- (void)reloadUrl;
@end
