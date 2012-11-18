//
//  PeopleController.h
//  UberClient
//
//  Created by Jordan Bonnet on 2/8/11.
//  Copyright 2011 Ubercab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyledLabel.h"

@interface Person : NSObject {
	long m_id;
	NSString *m_name;
	NSString *m_details;
	NSString *m_email;
	NSObject *m_tag;
	BOOL m_selected;
}

@property(nonatomic, readonly) long uid;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *details;
@property(nonatomic, readonly) NSObject *tag;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, assign) BOOL selected;

- (id)initWithId:(long)iUid andName:(NSString *)iName andDetails:(NSString *)iDetails andTag:(NSObject *)iTag;

@end


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
	int m_viewCount;
}

@property(nonatomic, retain) UITableView *tableView;

- (void)setPeople:(NSDictionary *)people;
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
