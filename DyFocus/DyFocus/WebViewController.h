
#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *m_webView;
    BOOL isFirstTime;
}

- (void)loadUrl:(NSString *)url;
@end
