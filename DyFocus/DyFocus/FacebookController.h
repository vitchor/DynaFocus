//
//  FacebookController.h
//  UberClient
//
//  Created by Jordan Bonnet on 2/8/11.
//  Copyright 2011 Ubercab LLC. All rights reserved.
//

#import "PeopleController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "InvitationController.h"

@interface FacebookController : PeopleController <InvitationDelegate, NSURLConnectionDelegate> {
	
	NSArray *m_permissions;
	NSString *m_message;
    //NSMutableData *data;
	int m_invitesLeftToSend;
}

@property (nonatomic, retain) NSString *message;

- (void)clearSession;
- (void)saveInvite:(long)contactId;
- (void)facebookError;
- (void)facebookSessionActive:(FBSession *)session;

// Overrides PeopleController
- (void)refreshPeople;
- (int)cellStyle;
- (void)loadImage:(int)uid;
- (void)sendInvite;


@end