//
//  InvitationController.h
//  UberClient
//
//  Created by Jordan Bonnet on 2/11/11.
//  Copyright 2011 Ubercab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InvitationDelegate

@required

- (NSString *)title;
- (NSString *)description;
- (NSString *)hintText;
- (void)saveInviteWithText:(NSString *)text;

@end


@interface InvitationController : UIViewController <UITextViewDelegate> {
	UITextView *m_messageView;
	id m_delegate;
}

@end
