//
//

#import "FacebookController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoadView.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "iToast.h"
#import "UIImageLoaderDyfocus.h"

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
		m_viewCount = 0;
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
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSMutableDictionary *allFriends = [[NSMutableDictionary alloc] init];

    for(id key in delegate.dyFriendsAtFace){
        [allFriends setObject:[delegate.dyFriendsAtFace objectForKey:key] forKey:key];
    }
    for(id key in delegate.dyFriendsFromFace){
        [allFriends setObject:[delegate.dyFriendsFromFace objectForKey:key] forKey:key];
    }
    [self setPeople:delegate.friendsFromFb andFriends:allFriends];
}

- (void)facebookError {
    
}

- (void)facebookSessionActive:(FBSession *)session {
    [self refreshPeople];
}

- (int)cellStyle {
	return UITableViewCellStyleDefault;
}


- (void)loadImage:(int)uid {
    
    Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:uid]];
    
    if (!person) {
        person = [m_friendInfo objectForKey:[NSNumber numberWithLong:uid]];
    }
    
    if(person){
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        [imageLoader loadPeopleProfilePicture:(NSString *)person.facebookId andImageCache:m_imageCache andUid:uid andTableView:self.tableView];
    }
}

- (NSString *)title {
	return @"Friends";
}

- (NSString *)description {
	return @"Customize your facebook direct message";
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

- (void)showFriendsWithToast:(NSString *)message {

    iToast *mToastMessage = [iToast makeText:NSLocalizedString(message, @"")];
    [[mToastMessage setDuration:iToastDurationNormal] show];
    
    [invitationController.navigationController dismissModalViewControllerAnimated:NO];

}

@end