//
//

#import "FacebookController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoadView.h"
#import "AppDelegate.h"
#import "NSURLConnectionWithDelegate.h"

#define FRIENDS_REQUEST 1
#define PICTURE_REQUEST 2
#define WALL_POST_REQUEST 3

@implementation FacebookController

@synthesize message = m_message;

- (id)init {
    if (self = [super init]) {
		self.title = @"Facebook";
		m_permissions =  [[NSArray arrayWithObjects:@"friends_about_me", @"publish_stream", nil] retain];
		m_invitesLeftToSend = 0;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *savedMessage = [defaults stringForKey:@"FacebookDefaultMessage"];
		if (savedMessage) {
			self.message = savedMessage;
		} else {
			self.message = @"Sign up for Dyfocus!";
		}
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[LoadView fadeAndRemoveFromView:self.view.window];
}

- (void)clearSession {
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AccessToken"];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ExpirationDate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self clearPeople];
	m_viewCount = 0;
}

- (void)refreshPeople {
 
    if(FBSession.activeSession.state == FBSessionStateOpen){
        
        
        [[FBRequest requestForMyFriends] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary* result,
           NSError *error) {
             if (!error) {
                 NSArray* friends = [result objectForKey:@"data"];
                 
                 NSMutableDictionary *people = [[[NSMutableDictionary alloc] initWithCapacity:[friends count]] autorelease];
                 
                 NSLog(@"Found: %i friends", friends.count);
                 for (NSDictionary<FBGraphUser>* friend in friends) {
                     NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                     Person *person = [[[Person alloc] initWithId:[friend.id longLongValue] andName:friend.name andDetails:@"" andTag:friend.id] autorelease];
                     [people setObject:person forKey:[NSNumber numberWithLong:[friend.id longLongValue]]];
                 }
                 
                 [self setPeople:people];
                 
                 //[LoadView fadeAndRemoveFromView:_app.window];
            }
         }];

        
    } else {
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openFacebookFriendsSession];
    }
   
}

- (void)facebookError {
    
}

- (void)facebookSessionActive:(FBSession *)session {
    [[FBRequest requestForMyFriends] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary* result,
       NSError *error) {
         if (!error) {
             NSArray* friends = [result objectForKey:@"data"];
             
             NSMutableDictionary *people = [[[NSMutableDictionary alloc] initWithCapacity:[friends count]] autorelease];
             
             NSLog(@"Found: %i friends", friends.count);
             for (NSDictionary<FBGraphUser>* friend in friends) {
                 NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                 Person *person = [[[Person alloc] initWithId:[friend.id longLongValue] andName:friend.name andDetails:@"" andTag:friend.id] autorelease];
                 [people setObject:person forKey:[NSNumber numberWithLong:[friend.id longLongValue]]];
             }
             
             [self setPeople:people];
         }
     }];

}

- (int)cellStyle {
	return UITableViewCellStyleDefault;
}


- (void)loadImage:(int)uid {
    
    Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:uid]];
    
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture",(NSString *)person.tag];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   if(image) {
                                       [self setImage:image withId:uid];
                                   }
                               }
                           }];
}


/*
- (void)fbDidLogin {
	[LoadView loadViewOnView:_app.window withText:@"Loading..."];
	[[NSUserDefaults standardUserDefaults] setObject:_app.facebook.accessToken forKey:@"AccessToken"];
	[[NSUserDefaults standardUserDefaults] setObject:_app.facebook.expirationDate forKey:@"ExpirationDate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	FBRequest *request = [_app.facebook requestWithGraphPath:@"me/friends" andTag:-1 andDelegate:self];
	request.type = FRIENDS_REQUEST;
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	[LoadView fadeAndRemoveFromView:_app.window];
	[self.navigationController popViewControllerAnimated:YES];
	[self clearSession];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	if (request.type == FRIENDS_REQUEST) {
		[LoadView fadeAndRemoveFromView:_app.window];
		simpleAlert(nil, @"Could not connect to Facebook. Please check your Internet Connection and try again.", nil);
		m_viewCount = 0;
	} else if (request.type == WALL_POST_REQUEST) {
		--m_invitesLeftToSend;
		if (m_invitesLeftToSend == 0) {
			[LoadView fadeAndRemoveFromView:_app.window];
			simpleAlert(nil, @"Could not connect to Facebook. Please check your Internet Connection and try again.", nil);
		}
	}
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if (request.type == FRIENDS_REQUEST) {
		NSArray *friends = [result valueForKey:@"data"];
		NSMutableDictionary *people = [[[NSMutableDictionary alloc] initWithCapacity:[friends count]] autorelease];
		for (NSDictionary *friend in friends) {
			long uid = [[friend objectForKey:@"id"] intValue];
			NSString *name = [friend objectForKey:@"name"];
			if (name) {
				Person *person = [[[Person alloc] initWithId:uid andName:name andDetails:@"" andTag:nil] autorelease];
				[people setObject:person forKey:[NSNumber numberWithLong:uid]];
			}
		}
		[self setPeople:people];
		[[NSUserDefaults standardUserDefaults] setInteger:[people count] forKey:[NSString stringWithFormat:@"%@%@", kUCFacebookTotal, _app.clientInfo.clientId]];
		[LoadView fadeAndRemoveFromView:_app.window];
	} else if (request.type == WALL_POST_REQUEST) {
		if (request.tag >= 0) {
			[self saveInvite:request.tag];
		}
		--m_invitesLeftToSend;
		if (m_invitesLeftToSend == 0) {
			NSArray *selectedIds = [self selectedIds];
			NSMutableArray *contacts = [[[NSMutableArray alloc] initWithCapacity:[selectedIds count]] autorelease];
			for (NSNumber *contactId in selectedIds) {
				[contacts addObject:[NSString stringWithFormat:@"%d", [contactId intValue]]];
			}
			[_app.service sendFacebookInvites:contacts];
			[self clearSelected];
		}
	} else if (request.type == PICTURE_REQUEST && request.tag >= 0) {
		if (result) {
			UIImage *image = [[[UIImage alloc] initWithData:(NSData*)result] autorelease];
			if (image) {
				[self setImage:image withId:request.tag];
			}
		}
	}
}

- (void)sendInvite {
	[LoadView loadViewOnView:_app.window withText:@"Sending..."];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
	[params setObject:m_message forKey:@"message"];
	[params setObject:_app.clientInfo.referralUrl forKey:@"link"];
	NSArray *selectedIds = [self selectedIds];
	m_invitesLeftToSend = [selectedIds count];
	for (NSNumber *contactId in selectedIds) {
		int friendId = [contactId intValue];
		NSString *graphPath = [[[NSString alloc] initWithFormat:@"%d/feed", friendId] autorelease];
		FBRequest *request = [_app.facebook requestWithGraphPath:graphPath andTag:friendId andParams:params andHttpMethod:@"POST" andDelegate:self];
		request.type = WALL_POST_REQUEST;
	}
}

- (void)saveInvite:(long)contactId {
	NSMutableDictionary *invitesToSave = nil;
	NSDictionary *savedInvites = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"%@%@", kUCFacebookInvites, _app.clientInfo.clientId]];
	if (savedInvites == nil) {
		invitesToSave = [[[NSMutableDictionary alloc] initWithCapacity:50] autorelease];
	} else {
		invitesToSave = [[[NSMutableDictionary alloc] initWithDictionary:savedInvites] autorelease];
	}	
	[invitesToSave setObject:@"1" forKey:[NSString stringWithFormat:@"%d", contactId]];
	[[NSUserDefaults standardUserDefaults] setObject:invitesToSave forKey:[NSString stringWithFormat:@"%@%@", kUCFacebookInvites, _app.clientInfo.clientId]];
}*/

- (NSString *)title {
	return @"Facebook";
}

- (NSString *)description {
	return @"Customize your wall post";
}

- (NSString *)hintText {
	return self.message;
}

- (void)saveInviteWithText:(NSString *)text {
	self.message = text;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:text forKey:@"FacebookDefaultMessage"];
}

@end