
#import <UIKit/UIKit.h>
#import "UIStyledLabel.h"
#import "InvitationController.h"

@interface PeopleController : UIViewController  /*Extends a Table of Cells */<
                                  UITableViewDataSource /*Used to edit table's content*/,
                                  UITableViewDelegate   /*Used to capture interaction in the tables*/,
                                  UISearchBarDelegate   /*Used to capture interaction with the searchBar*/> {
	// UI
	UITableView *m_tableView;                   // The Table
	UISearchBar *m_searchBar;                   // Search Bar on the top of the view
	UIToolbar *m_controlToolbar;                // Gray Bar with All/Selected(#) button and "Send Invitations >"
	UISegmentedControl *m_swithSelectedButton;  // All/Selected Button
	UIStyledLabel *m_customMessageLabel;        // @"Send Invitations >" label
	BOOL m_isFacebookTableEmpty;
	BOOL m_isDyfocusTableEmpty;
	
	// Model
	NSMutableDictionary *m_peopleInfo;          // ??
	NSMutableArray *m_visiblePeopleList;        // ??
	NSMutableDictionary *m_imageCache;          // Available to invite section
	NSMutableDictionary *m_friendInfo;          // Friend Section
	NSMutableArray *m_visibleFriendsList;
    InvitationController *invitationController;
    
	int m_viewCount;                            //??
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
