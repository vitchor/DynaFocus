

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol InvitationDelegate

@required

- (NSString *)title;
- (NSString *)description;
- (NSString *)hintText;
- (void)saveInviteWithText:(NSString *)text;

@end


@interface InvitationController : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate> {
	UITextView *m_messageView;
	id m_delegate;
    NSMutableArray *selectedPeople;
    UIView *infoView;
}


@property(nonatomic, retain) NSMutableArray *selectedPeople;
@property(nonatomic, retain) UIView *infoView;

@end
