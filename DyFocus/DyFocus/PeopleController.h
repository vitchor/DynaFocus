
#import <UIKit/UIKit.h>
#import "UIStyledLabel.h"
#import "InvitationController.h"
#import "FriendProfileController.h"

@interface PeopleController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	// UI
	UITableView *m_tableView;
	UISearchBar *m_searchBar;
	UIToolbar *m_controlToolbar;
	UISegmentedControl *m_swithSelectedButton;
	UIStyledLabel *m_customMessageLabel;
	BOOL m_isFacebookTableEmpty;
	BOOL m_isDyfocusTableEmpty;
	
	// Model
	NSMutableDictionary *m_peopleInfo;
	NSMutableArray *m_visiblePeopleList;
	NSMutableDictionary *m_imageCache;
    
	NSMutableDictionary *m_friendInfo;
	NSMutableArray *m_visibleFriendsList;
    
    InvitationController *invitationController;
    
	int m_viewCount;
}

@property(nonatomic, retain) UITableView *tableView;

- (void)setPeople:(NSMutableDictionary *)people andFriends:(NSMutableDictionary *)friends;
- (void)refreshImages;
- (void)setImage:(UIImage *)image withId:(int)uid;
- (void)clearImageCache;
- (void)switchSelect:(int)index;
- (void)showAll;
- (void)showSelected;
- (void)filterWithText:(NSString*)text;
- (NSArray *)selectedIds;
- (void)clearSelected;
- (void)clearPeople;

// To be implemented by derived classes
- (void)refreshPeople;
- (int)cellStyle;
- (void)loadImage:(int)uid;
- (void)sendInvite;

static int comparePerson(id personId1, id personId2, void *context);

@end
