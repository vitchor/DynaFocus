//
//

#import "FacebookController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoadView.h"
#import "AppDelegate.h"
#import "JSON.h"

#define FRIENDS_REQUEST 1
#define PICTURE_REQUEST 2
#define WALL_POST_REQUEST 3

@implementation FacebookController

@synthesize message = m_message;

- (id)init {
    if (self = [super init]) {
		self.title = @"Friends";
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
        [LoadView loadViewOnView: self.view withText:@"Loading..."];

        [[FBRequest requestForMyFriends] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary* result,
           NSError *error) {
             if (!error) {
                 NSArray* friends = [result objectForKey:@"data"];
                 
                 NSMutableDictionary *people = [[[NSMutableDictionary alloc] initWithCapacity:[friends count]] autorelease];
                 
                 NSMutableArray *jsonFriends = [[[NSMutableArray alloc] initWithCapacity:[friends count]] autorelease];
                 
                 NSLog(@"Found: %i friends", friends.count);
                 
                 for (NSDictionary<FBGraphUser>* friend in friends) {
                     NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                     Person *person = [[[Person alloc] initWithId:[friend.id longLongValue] andName:friend.name andDetails:@"" andTag:friend.id] autorelease];
                     [people setObject:person forKey:[NSNumber numberWithLong:[friend.id longLongValue]]];
                     
                     
                     //Creates json object and add to the request object
                      NSMutableDictionary *jsonFriendObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
                     [jsonFriendObject setObject:friend.id forKey:@"facebook_id"];
                     [jsonFriends addObject:jsonFriendObject];
                     
                 }
                 
                 //Structure that will become the JSON object, in the facebook_friends dyfocus request:
                 NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
                 [jsonRequestObject setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"user_device_id"];
                 [jsonRequestObject setObject:jsonFriends forKey:@"friends"];
                 
                 NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
                 
                 NSLog(@"JSON DONE: %@", json);
                 
                 
                 //Let's send the request, then:
                 NSURL *webServiceUrl = [NSURL URLWithString:@"http://dyfoc.us/uploader/user_fb_friends/"];
                 
                 NSString *postString = [[NSString alloc] initWithFormat:@"json=%@", json];
                 
                 NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:webServiceUrl];
                 
                 [postRequest setHTTPMethod:@"POST"];
                 
                 [postRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 
                 NSURLResponse *response;
                 NSHTTPURLResponse *httpResponse;
                 NSData *dataReply;
                 NSString *stringReply;
                 
                 dataReply = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&error];
                 stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
                 httpResponse = (NSHTTPURLResponse *)response;
                 int statusCode = [httpResponse statusCode];
                 
                  NSLog(@"JSON RESPONSE: %@",stringReply);
                 
                 NSMutableDictionary *friendsDictionary = [[NSMutableDictionary alloc] init];
                                                 
                 if (statusCode == 200) {
                     // Let's parse the response and create a NSMutableDictonary with the friends:
                     
                     if (stringReply) {
                         NSDictionary *jsonValues = [stringReply JSONValue];
                         
                         if (jsonValues) {
                             NSDictionary * jsonFriends = [jsonValues valueForKey:@"friends_list"];
                             
                             if (jsonFriends) {
                                 
                                 for (int i = 0; i < [jsonFriends count]; i++) {
                                     
                                     NSDictionary *jsonFriend = [jsonFriends objectAtIndex:i];
                                     NSString *friendId = [jsonFriend valueForKey:@"facebook_id"];
                                     
                                     Person *person = [people objectForKey:[NSNumber numberWithLong:[friendId longLongValue]]];
                                     
                                     [friendsDictionary setObject:person forKey:[NSNumber numberWithLong:[person.tag longLongValue]]];
                                     [people removeObjectForKey:[NSNumber numberWithLong:[person.tag longLongValue]]];
                                 }
                                 
                                 [self setPeople:people andFriends:friendsDictionary];
                                 [LoadView fadeAndRemoveFromView:self.view];
                             }
                         }
                     }
                    
                     
                 } else {
                     // Let's deal with the failure:
                     [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Network Error"];
                 }
                 

                 [postString release];
                 
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
    
    if (!person) {
        person = [m_friendInfo objectForKey:[NSNumber numberWithLong:uid]];
    }
    
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
	return @"Friends";
}

- (NSString *)description {
	return @"Customize your facebook message";
}

- (NSString *)hintText {
	return self.message;
}

- (void)saveInviteWithText:(NSString *)text {
	self.message = text;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:text forKey:@"FacebookDefaultMessage"];
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

@end