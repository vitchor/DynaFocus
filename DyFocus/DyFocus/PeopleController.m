//
//  ContactsController.m
//  UberClient
//
//  Created by Jordan Bonnet on 2/8/11.
//  Copyright 2011 Ubercab LLC. All rights reserved.
//

#import "PeopleController.h"
#import "InvitationController.h"
#import "AppDelegate.h"

@implementation Person

@synthesize uid = m_id, name = m_name, details = m_details, tag = m_tag, email = m_email, selected = m_selected;

- (id)initWithId:(long)iUid andName:(NSString *)iName andDetails:(NSString *)iDetails andTag:(NSObject *)iTag {
	if (self = [super init]) {
		m_id = iUid;
		m_name = [iName retain];
		m_details = [iDetails retain];
		m_tag = [iTag retain];
		m_selected = NO;
		self.email = @"";
	}
	return self;
}

- (void)dealloc {
	/*RELEASE_MEMBER(m_name);
	RELEASE_MEMBER(m_details);
	RELEASE_MEMBER(m_tag);
	RELEASE_MEMBER(m_email);*/
	[super dealloc];
}

@end


@implementation PeopleController

@synthesize tableView = m_tableView;

- (id)init {
    if (self = [super init]) {
		self.navigationItem.hidesBackButton = NO;
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendAction)] autorelease];
		
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)] autorelease];

        
		// Model
		m_peopleInfo = [[NSMutableDictionary alloc] initWithCapacity:50];
		m_visiblePeopleList = [[NSMutableArray alloc] initWithCapacity:50];
		m_imageCache = [[NSMutableDictionary alloc] initWithCapacity:50];
		m_viewCount = 0;
		
		// UI
		m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 326) style:UITableViewStylePlain];
		[m_tableView setRowHeight:50.0];
		m_tableView.dataSource = self;
		m_tableView.delegate = self;
		[self.view addSubview:m_tableView];
		
		m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		m_searchBar.delegate = self;
		m_searchBar.barStyle = UIBarStyleBlackOpaque;
		m_searchBar.placeholder = @"Search people";		
		[self.view addSubview:m_searchBar];
		
		// Init toolbar
		m_controlToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 366, 320, 50)];
		m_controlToolbar.tintColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
		// Personalize message button
		UIView *customMessageView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 135, 35)] autorelease];
		UIButton *customMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		customMessageButton.frame = CGRectMake(0, 0, 135, 35);
		customMessageButton.backgroundColor = [UIColor colorWithWhite:0.0/255 alpha:0.0];
		[customMessageButton addTarget:self action:@selector(customMessageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[customMessageButton addTarget:self action:@selector(customMessageButtonTouchDown) forControlEvents:UIControlEventTouchDown];
		[customMessageButton addTarget:self action:@selector(customMessageButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
		[customMessageView addSubview:customMessageButton];
		// Personalize message label
		m_customMessageLabel = [[UIStyledLabel alloc] initWithFrame:CGRectMake(0, 0, 135, 35)];
		m_customMessageLabel.textColor = [UIColor blackColor];
		m_customMessageLabel.shadowOffset = CGSizeMake(0,1);
		m_customMessageLabel.shadowColor = [UIColor whiteColor];
		m_customMessageLabel.font = [UIFont systemFontOfSize:13];
		m_customMessageLabel.backgroundColor = [UIColor colorWithWhite:0.0/255 alpha:0.0];
		m_customMessageLabel.text = @"Custom message";
		[customMessageView addSubview:m_customMessageLabel];
		UIBarButtonItem *customMessageViewItem = [[[UIBarButtonItem alloc] initWithCustomView:customMessageView] autorelease];
		// Flex space
		UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		// Swith All/Selected buttons
		m_swithSelectedButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Selected", nil]];
		m_swithSelectedButton.segmentedControlStyle = UISegmentedControlStyleBar;
		m_swithSelectedButton.selectedSegmentIndex = 0;
		m_swithSelectedButton.tintColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
		m_swithSelectedButton.frame = CGRectMake(0, 0, 160, 33);
		[m_swithSelectedButton addTarget:self action:@selector(switchSelectedClicked:) forControlEvents:UIControlEventValueChanged];
		UIBarButtonItem *switchSelected = [[[UIBarButtonItem alloc] initWithCustomView:m_swithSelectedButton] autorelease];
		// Set items on toolbar
		[m_controlToolbar setItems:[NSArray arrayWithObjects:customMessageViewItem, flex, switchSelected, nil]];
		[self.view addSubview:m_controlToolbar];
	}
	return self;
}

- (void)cancelAction {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate goBackToLastController];
}

- (void)dealloc {
	// UI
	/*RELEASE_MEMBER(m_tableView);
	RELEASE_MEMBER(m_searchBar);
	RELEASE_MEMBER(m_controlToolbar);
	RELEASE_MEMBER(m_swithSelectedButton);
	RELEASE_MEMBER(m_customMessageLabel);
	// Model
	RELEASE_MEMBER(m_peopleInfo);
	RELEASE_MEMBER(m_visiblePeopleList);
	RELEASE_MEMBER(m_imageCache);*/
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (m_viewCount == 0) {
		[self refreshPeople];
	}
	++m_viewCount;
	if (m_viewCount >= 5) {
		m_viewCount = 0;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView reloadData];
	[self refreshImages];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int count = [m_visiblePeopleList count];
	if (count > 0) {
		m_isTableEmpty = NO;
		return count;
	}
	m_isTableEmpty = YES;
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (m_isTableEmpty) {
		NSString *cellId = @"empty";
		cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:cellId] autorelease];
		}
		cell.textLabel.text = @"No contacts were found";
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont systemFontOfSize:20];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryView = nil;
		cell.imageView.image = nil;
	} else {
		NSString *cellId = [NSString stringWithFormat:@"%d", indexPath.row];
		cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:cellId] autorelease];
		}
		NSNumber *personIdNumber = [m_visiblePeopleList objectAtIndex:indexPath.row];
		if (personIdNumber) {
			long personId = [personIdNumber longValue];
            
            NSLog(@"FIRST APPERANCE: %ld", personId);
			Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:personId]];
			cell.textLabel.text = person.name;
			cell.detailTextLabel.text = person.details;
			cell.tag = personId;
			UIImage *image = [m_imageCache objectForKey:[NSNumber numberWithLong:personId]];
			if (image == nil) {
				image = [UIImage imageNamed:@"AvatarDefault.png"];
			}
			cell.imageView.image = image;
			if (person.selected == NO) {
				// Not invited yet
				UISegmentedControl *inviteButton = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Select"]] autorelease];
				inviteButton.segmentedControlStyle = UISegmentedControlStyleBar;
				inviteButton.momentary = YES;
				inviteButton.tintColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0];
				inviteButton.frame = CGRectMake(0, 10, 65, 30);
				inviteButton.tag = indexPath.row;
				[inviteButton addTarget:self action:@selector(inviteButtonClicked:) forControlEvents:UIControlEventValueChanged];
				cell.accessoryView = inviteButton;
			} else {
				// Already invited
				UISegmentedControl *invitedButton = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Selected"]] autorelease];
				invitedButton.segmentedControlStyle = UISegmentedControlStyleBar;
				invitedButton.momentary = YES;
				invitedButton.tintColor = [UIColor colorWithRed:76.0/255 green:196.0/255 blue:23.0/255 alpha:1.0];
				invitedButton.frame = CGRectMake(0, 10, 65, 30);
				invitedButton.tag = indexPath.row;
				[invitedButton addTarget:self action:@selector(inviteButtonClicked:) forControlEvents:UIControlEventValueChanged];
				cell.accessoryView = invitedButton;
			}
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self switchSelect:indexPath.row];
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[m_searchBar resignFirstResponder];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self refreshImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate == NO) {
		[self refreshImages];
	}
}

- (void)refreshImages {
	if (!m_isTableEmpty) {
		NSArray *visibleCells = [self.tableView visibleCells];
		if (visibleCells) {
			NSArray *visibleCellsCopy = [[NSArray alloc] initWithArray:visibleCells];
			for (UITableViewCell *cell in visibleCellsCopy) {
				UIImage *image = [m_imageCache objectForKey:[NSNumber numberWithInt:cell.tag]];
				if (image == nil) {
					[self loadImage:cell.tag];
				}
			}
			[visibleCellsCopy release];
		}
	}
}

- (void)clearImageCache {
	[m_imageCache removeAllObjects];
}

- (void)filterWithText:(NSString*)text {
	[m_visiblePeopleList removeAllObjects];
	NSString *lowerText = [text lowercaseString];
	NSArray *allPeople = [m_peopleInfo allKeys];
	for (int i = 0; i < [allPeople count]; ++i) {
		long uid = [[allPeople objectAtIndex:i] longValue];
		Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:uid]];
		NSString *personName = [person.name lowercaseString];
		if ([lowerText length] == 0 || [personName rangeOfString:lowerText].location != NSNotFound) {
			[m_visiblePeopleList addObject:[NSNumber numberWithLong:person.uid]];
		}
	}
	[m_visiblePeopleList sortUsingFunction:comparePerson context:m_peopleInfo];
}

- (void)refreshPeople {
}

- (void)setPeople:(NSMutableDictionary *)people {
	[m_peopleInfo release];
	m_peopleInfo = [people retain];
	[m_visiblePeopleList removeAllObjects];
	[m_visiblePeopleList setArray:[m_peopleInfo allKeys]];
	[m_visiblePeopleList sortUsingFunction:comparePerson context:m_peopleInfo];
	[m_swithSelectedButton setTitle:@"Selected (0)" forSegmentAtIndex:1];
	[m_swithSelectedButton setEnabled:NO forSegmentAtIndex:1];
	[self.tableView reloadData];
	[self refreshImages];
}

- (int)cellStyle {
	return UITableViewCellStyleDefault;
}

- (void)loadImage:(int)uid {
	// To be overridden
}

- (void)setImage:(UIImage *)image withId:(int)uid {
	[m_imageCache setObject:image forKey:[NSNumber numberWithInt:uid]];
	[self.tableView reloadData];
}

- (IBAction)inviteButtonClicked:(id)sender {
	UISegmentedControl *inviteButton = (UISegmentedControl *)sender;
	[self switchSelect:inviteButton.tag];
}

- (void)switchSelect:(int)index {
	[m_searchBar resignFirstResponder];
	Person *person = [m_peopleInfo objectForKey:[m_visiblePeopleList objectAtIndex:index]];
	person.selected = !person.selected;
	int selectedCount = [[self selectedIds] count];
	[m_swithSelectedButton setTitle:[NSString stringWithFormat:@"Selected (%d)", selectedCount] forSegmentAtIndex:1];
	[m_swithSelectedButton setEnabled:(selectedCount > 0) forSegmentAtIndex:1];
	[self.tableView reloadData];
}

- (NSArray *)selectedIds {
	int peopleCount = [m_peopleInfo count];
	NSMutableArray *selectedList = [[[NSMutableArray alloc] initWithCapacity:peopleCount] autorelease];
	if (peopleCount > 0) {
		NSArray *allPeopleIds = [m_peopleInfo allKeys];
		for (NSNumber *peopleId in allPeopleIds) {
			Person *person = [m_peopleInfo objectForKey:peopleId];
			if (person.selected) {
				[selectedList addObject:peopleId];
			}
		}
	}
	return selectedList;
}

- (void)clearSelected {
	NSArray *allPeopleIds = [m_peopleInfo allKeys];
	for (NSNumber *peopleId in allPeopleIds) {
		Person *person = [m_peopleInfo objectForKey:peopleId];
		person.selected = NO;
	}
	[m_swithSelectedButton setTitle:@"Selected (0)" forSegmentAtIndex:1];
	[m_swithSelectedButton setEnabled:NO forSegmentAtIndex:1];
	[self showAll];
}

- (void)clearPeople {
	[m_peopleInfo removeAllObjects];
	[m_visiblePeopleList removeAllObjects];
	[self.tableView reloadData];
	[self clearImageCache];
}

- (void)showAll {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	m_searchBar.alpha = 1.0;
	m_searchBar.frame = CGRectMake(0, 0, 320, 40);
	self.tableView.frame = CGRectMake(0, 40, 320, 326);
	[UIView commitAnimations];
	
	m_swithSelectedButton.selectedSegmentIndex = 0;
	[self filterWithText:[m_searchBar text]];
	[self.tableView reloadData];
	[self refreshImages];
}

- (void)showSelected {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	m_searchBar.alpha = 0.0;
	m_searchBar.frame = CGRectMake(0, -40, 320, 40);
	self.tableView.frame = CGRectMake(0, 0, 320, 366);
	[UIView commitAnimations];
	
	m_swithSelectedButton.selectedSegmentIndex = 1;
	[m_visiblePeopleList setArray:[self selectedIds]];
	[m_visiblePeopleList sortUsingFunction:comparePerson context:m_peopleInfo];
	[self.tableView reloadData];
}

- (void)sendAction {
	int selectedCount = [[self selectedIds] count];
	if (selectedCount == 0) {
		//simpleAlert(nil, @"Please select at least one friend.", nil);
	} else {
		[self sendInvite];
	}
}

- (void)sendInvite {
}

- (void)personalizeMessage {
	InvitationController *ctlr = [[[InvitationController alloc] initWithDelegate:self] autorelease];
	UINavigationController *navCtlr = [[[UINavigationController alloc] initWithRootViewController:ctlr] autorelease];
	navCtlr.navigationBar.barStyle = UIBarStyleBlackOpaque;			
	[self presentModalViewController:navCtlr animated:YES];
}

- (IBAction)switchSelectedClicked:(id)sender {
	UISegmentedControl *switchSelected = (UISegmentedControl *)sender;
	if (switchSelected.selectedSegmentIndex == 0) {
		[self showAll];
	} else if (switchSelected.selectedSegmentIndex == 1) {
		[self showSelected];
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	for (UIView *possibleButton in searchBar.subviews) {
		if ([possibleButton isKindOfClass:[UIButton class]]) {
			[self performSelector:@selector(customizeSearchButton:) withObject:(UIButton*)possibleButton afterDelay:.1];			break;
		}
	}
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	self.tableView.frame = CGRectMake(0, 40, 320, 420);
	[m_controlToolbar removeFromSuperview];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	for (UIView *possibleButton in searchBar.subviews) {
		if ([possibleButton isKindOfClass:[UIButton class]]) {
			[self performSelector:@selector(customizeSearchButton:) withObject:(UIButton*)possibleButton afterDelay:.1];
			break;
		}
	}
}

- (void)customizeSearchButton:(id)object {
	UIButton *cancelButton = (UIButton *)object;
	[cancelButton setTitle:@"Done" forState:UIControlStateNormal];
	cancelButton.enabled = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar setText:@""];
	[searchBar resignFirstResponder];	
	[searchBar setShowsCancelButton:NO animated:YES];	
	[self.navigationController setNavigationBarHidden:NO animated:YES];	
	self.tableView.frame = CGRectMake(0, 40, 320, 326);
	[self.view addSubview:m_controlToolbar];
	[self showAll];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self performSelector:@selector(updateTable:) withObject:searchText afterDelay:.1];
}

- (void)updateTable:(id)object {
	NSString *filterText = (NSString *)object;
	if (filterText) {
		[self filterWithText:filterText];
		[self.tableView reloadData];
		[self refreshImages];
	}
}

- (void)customMessageButtonClicked {
	[self personalizeMessage];
	m_customMessageLabel.textColor = [UIColor blackColor];
}

- (void)customMessageButtonTouchDown {
	m_customMessageLabel.textColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:150.0/255 alpha:1.0];
}

- (void)customMessageButtonTouchUpOutside {
	m_customMessageLabel.textColor = [UIColor blackColor];
}

static int comparePerson(id personId1, id personId2, void *context) {
	if (personId1 == nil || personId2 == nil) {
		return NSOrderedSame;
	}
	NSDictionary *peopleInfo = (NSDictionary *)context;
	Person *person1 = [peopleInfo objectForKey:(NSNumber *)personId1];
	Person *person2 = [peopleInfo objectForKey:(NSNumber *)personId2];
	return [person1.name compare:person2.name];
}

@end
