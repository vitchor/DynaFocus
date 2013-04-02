
#import "PeopleController.h"
#import "InvitationController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "DyfocusUINavigationController.h"
#import "FOFTableController.h"
#import "Person.h"

@implementation PeopleController

@synthesize tableView = m_tableView;

- (id)init {
    if (self = [super init]) {
		self.navigationItem.hidesBackButton = NO;
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Send Invites" style:UIBarButtonItemStyleDone target:self action:@selector(sendAction)] autorelease];
        self.navigationItem.rightBarButtonItem.enabled = NO;
		
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)] autorelease];

        
		// Model
        m_peopleInfo = [[NSMutableDictionary alloc] initWithCapacity:20];
        m_friendInfo = [[NSMutableDictionary alloc] initWithCapacity:20];
		
        m_visiblePeopleList = [[NSMutableArray alloc] initWithCapacity:20];
        m_visibleFriendsList = [[NSMutableArray alloc] initWithCapacity:20];
		
        m_imageCache = [[NSMutableDictionary alloc] initWithCapacity:20];
        m_viewCount = 0;
		
		// UI
	
        //Changes tableView bounds according to the screen size of the iPhone:
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 480) style:UITableViewStylePlain];
        } else {
            m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 392) style:UITableViewStylePlain];
        }
        
        //Defines table characteristics
		[m_tableView setRowHeight:50.0];
		m_tableView.dataSource = self;  //First Include
		m_tableView.delegate = self;    //Second Include
		[self.view addSubview:m_tableView];
		
        //Defines searchBar characteristics
		m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		m_searchBar.delegate = self;    //Third Include
		m_searchBar.barStyle = UIBarStyleBlackOpaque;
		m_searchBar.placeholder = @"Search people";		
		[self.view addSubview:m_searchBar];
		
		// Init toolbar
		m_controlToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 30, 320, 40)];
		m_controlToolbar.tintColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:0.9];
		// Personalize message button
		UIView *customMessageView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 135, 35)] autorelease];
		UIButton *customMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		customMessageButton.frame = CGRectMake(0, 0, 135, 35);
		customMessageButton.backgroundColor = [UIColor colorWithWhite:0.0/255 alpha:0.0];
		[customMessageButton addTarget:self action:@selector(customMessageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[customMessageButton addTarget:self action:@selector(customMessageButtonTouchDown) forControlEvents:UIControlEventTouchDown];
		[customMessageButton addTarget:self action:@selector(customMessageButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
		[customMessageView addSubview:customMessageButton];
		// Personalize message label
		m_customMessageLabel = [[UIStyledLabel alloc] initWithFrame:CGRectMake(4, 0, 135, 35)];
		m_customMessageLabel.textColor = [UIColor lightGrayColor];
		m_customMessageLabel.shadowOffset = CGSizeMake(0.45, 1.5);
		//m_customMessageLabel.shadowColor = [UIColor whiteColor];
		m_customMessageLabel.font = [UIFont boldSystemFontOfSize:14];
		m_customMessageLabel.backgroundColor = [UIColor colorWithWhite:0.0/255 alpha:0.0];
		m_customMessageLabel.text = @"Send Invitations >";
        
        //m_customMessageLabel.textAlignment = kCTRightTextAlignment;
		[customMessageView addSubview:m_customMessageLabel];
		UIBarButtonItem *customMessageViewItem = [[[UIBarButtonItem alloc] initWithCustomView:customMessageView] autorelease];
		// Flex space
		UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        flex.width = 30;
		// Swith All/Selected buttons
		m_swithSelectedButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Selected", nil]];
		m_swithSelectedButton.segmentedControlStyle = UISegmentedControlStyleBar;
		m_swithSelectedButton.selectedSegmentIndex = 0;
		m_swithSelectedButton.tintColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
		m_swithSelectedButton.frame = CGRectMake(35, 0, 170, 33);
		[m_swithSelectedButton addTarget:self action:@selector(switchSelectedClicked:) forControlEvents:UIControlEventValueChanged];
		UIBarButtonItem *switchSelected = [[[UIBarButtonItem alloc] initWithCustomView:m_swithSelectedButton] autorelease];
        
		// Set items on toolbar
		[m_controlToolbar setItems:[NSArray arrayWithObjects: switchSelected, customMessageViewItem, nil]];
        m_controlToolbar.alpha = 0.9;
		//[self.view addSubview:m_controlToolbar];
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
    [self.navigationController setNavigationBarHidden:YES animated:FALSE];
	[super viewWillAppear:animated];
    [self refreshPeople];
    
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
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"PeopleController.viewDidAppear"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        int count = [m_visibleFriendsList count];
        if (count > 0) {
            m_isDyfocusTableEmpty = NO;
            return count;
        }
        
        m_isDyfocusTableEmpty = YES;
        
        return 1;
        
    } else {
        
        int count = [m_visiblePeopleList count];
        if (count > 0) {
            m_isFacebookTableEmpty = NO;
            return count;
        }
        
        m_isFacebookTableEmpty = YES;
        
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0 || [m_searchBar showsCancelButton]) {
        return 30;
        
    } else {
        return 30 + m_controlToolbar.frame.size.height;
        
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Friends using dyfocus";
    } else {
        return @"Select friends to invite";
    }
}




-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   if (section == 0 || [m_searchBar showsCancelButton]) {
        CGRect aFrame =CGRectMake(0, 0, tableView.contentSize.width, 30);
        UIView * aView = [[[UIView alloc] initWithFrame:aFrame] autorelease];
        aView.backgroundColor = UIColor.clearColor;
        
        // Create a stretchable image for the background that emulates the default gradient, only in green
        UIImage *viewBackgroundImage = [[UIImage imageNamed:@"gray_background.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        
        // Cannot set this image directly as the background of the cell because
        // the background needs to be offset by 1pix at the top to cover the previous cell border (Alex Deplov's requirement ^_^)
        CALayer *backgroungLayer = [CALayer layer];
        
        backgroungLayer.frame = CGRectMake(0, -1, tableView.contentSize.width, 30 + 1);
        backgroungLayer.contents = (id) viewBackgroundImage.CGImage;
        backgroungLayer.masksToBounds = NO;
        backgroungLayer.opacity = 0.9;
        [aView.layer addSublayer:backgroungLayer];
        
        // Take care of the section title now
        UILabel *aTitle = [[[UILabel alloc] initWithFrame: CGRectMake(10, 0, aView.bounds.size.width-10, aView.bounds.size.height)] autorelease];
        aTitle.text = [self tableView:tableView titleForHeaderInSection:section];
        aTitle.backgroundColor = UIColor.clearColor;
        aTitle.font = [UIFont boldSystemFontOfSize:18];
        aTitle.textColor = UIColor.whiteColor;
        
        // Text shadow
        aTitle.layer.shadowOffset = CGSizeMake(0, 1);
        aTitle.layer.shadowRadius = .2;
        aTitle.layer.masksToBounds = NO;
        aTitle.layer.shadowOpacity = 0.5;
        aTitle.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        [aView addSubview:aTitle];
        
        return aView;
    } else {
        CGRect aFrame = CGRectMake(0, 0, tableView.contentSize.width, 30 + m_controlToolbar.frame.size.height);
        UIView * aView = [[[UIView alloc] initWithFrame:aFrame] autorelease];
        aView.backgroundColor = UIColor.clearColor;
        
        // Create a stretchable image for the background that emulates the default gradient, only in green
        UIImage *viewBackgroundImage = [[UIImage imageNamed:@"gray_background.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        
        // Cannot set this image directly as the background of the cell because
        // the background needs to be offset by 1pix at the top to cover the previous cell border (Alex Deplov's requirement ^_^)
        CALayer *backgroungLayer = [CALayer layer];
        
        backgroungLayer.frame = CGRectMake(0, -1, tableView.contentSize.width, 30 + 1);
        backgroungLayer.contents = (id) viewBackgroundImage.CGImage;
        backgroungLayer.masksToBounds = NO;
        backgroungLayer.opacity = 0.9;
        [aView.layer addSublayer:backgroungLayer];
        
        // Take care of the section title now
        UILabel *aTitle = [[[UILabel alloc] initWithFrame: CGRectMake(10, 0, aView.bounds.size.width-10, 30)] autorelease];
        aTitle.text = [self tableView:tableView titleForHeaderInSection:section];
        aTitle.backgroundColor = UIColor.clearColor;
        aTitle.font = [UIFont boldSystemFontOfSize:18];
        aTitle.textColor = UIColor.whiteColor;
        
        // Text shadow
        aTitle.layer.shadowOffset = CGSizeMake(0, 1);
        aTitle.layer.shadowRadius = .2;
        aTitle.layer.masksToBounds = NO;
        aTitle.layer.shadowOpacity = 0.5;
        aTitle.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        [aView addSubview:aTitle];
        [aView addSubview:m_controlToolbar];
        
        return aView;
    }
    
}

- (CAGradientLayer *) greyGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    
    UIColor *color1 = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
    
    [gradient setColors:[NSArray arrayWithObjects:(id)color1.CGColor, (id)color2.CGColor, nil]];
    return gradient;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (m_isDyfocusTableEmpty) {
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
            
            NSString *cellId = [NSString stringWithFormat:@"0_%d", indexPath.row];
            cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:cellId] autorelease];
            }
            NSNumber *personIdNumber = [m_visibleFriendsList objectAtIndex:indexPath.row];
            if (personIdNumber) {
                long personId = [personIdNumber longValue];
                
                Person *person = [m_friendInfo objectForKey:[NSNumber numberWithLong:personId]];
                cell.textLabel.text = person.name;
                cell.detailTextLabel.text = person.facebookUserName;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.tag = personId;
                
                UIImage *image = [m_imageCache objectForKey:[NSNumber numberWithLong:personId]];
                
                if (image == nil) {
                    image = [UIImage imageNamed:@"AvatarDefault.png"];
                }
                
                cell.imageView.image = image;
            }
        }
    } else {
        if (m_isFacebookTableEmpty) {
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
            
            NSString *cellId = [NSString stringWithFormat:@"1_%d", indexPath.row];
            cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:cellId] autorelease];                
            }
            
            NSNumber *personIdNumber = [m_visiblePeopleList objectAtIndex:indexPath.row];
            
            if (personIdNumber) {
                long personId = [personIdNumber longValue];
                
                Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:personId]];
                cell.textLabel.text = person.name;
                cell.detailTextLabel.text = person.facebookUserName;
                cell.tag = personId;
                UIImage *image = [m_imageCache objectForKey:[NSNumber numberWithLong:personId]];
                if (image == nil) {
                    image = [UIImage imageNamed:@"AvatarDefault.png"];
                }
                cell.imageView.image = image;
                
                if (person.selected == NO) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    //((UILabel *)cell.accessoryView).textColor = [UIColor colorWithRed:8.0/255.0 green:82.0/255.0 blue:190.0/255.0 alpha:1.0];
                    
                } else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    //((UILabel *)cell.accessoryView).textColor = [UIColor colorWithRed:0.04 green:0.7 blue:0.04 alpha:1.0];
                }
            }
        }
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
        
        NSMutableArray *selectedPersonFofs = [NSMutableArray array];
        Person *person = nil;
        NSNumber *personIdNumber = [m_visibleFriendsList objectAtIndex:indexPath.row];
        
        if (personIdNumber) {
            
            long personId = [personIdNumber longValue];
            
            person = [m_friendInfo objectForKey:[NSNumber numberWithLong:personId]];
            
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            
            delegate.currentFriend = person;
            
            for (FOF *fof in delegate.feedFofArray) {
                
                if ([fof.m_userId isEqualToString: [NSString stringWithFormat: @"%@", person.facebookId]]) {
                    
                    [selectedPersonFofs addObject:fof];
                    
                }
            }
            
            delegate.friendFofArray = selectedPersonFofs;

        }
                    
        FriendProfileController *friendProfileController = [[FriendProfileController alloc] init];
        
        friendProfileController.hidesBottomBarWhenPushed = YES;

        [friendProfileController clearCurrentUser];
        
        [self.navigationController pushViewController:friendProfileController animated:true];
        [self.navigationController setNavigationBarHidden:NO animated:TRUE];

        
    } else {
        [self switchSelect:indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
	
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
	if (!m_isFacebookTableEmpty) {
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
	[m_visibleFriendsList removeAllObjects];
    
    NSString *lowerText = [text lowercaseString];
//    [self.dyFriendsFromFace setObject:person forKey:[NSNumber numberWithLong:[person.facebookId longLongValue]]];
	NSArray *allPeople = [m_peopleInfo allKeys];
    NSArray *allFriends = [m_friendInfo allKeys];
    
	for (int i = 0; i < [allPeople count]; ++i) {
		long uid = [[allPeople objectAtIndex:i] longValue];
		Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:uid]];
        
		NSString *personName = [person.name lowercaseString];
		if ([lowerText length] == 0 || [personName rangeOfString:lowerText].location != NSNotFound) {
			[m_visiblePeopleList addObject:[NSNumber numberWithLong:[person.facebookId longLongValue]]];
		}
	}
	[m_visiblePeopleList sortUsingFunction:comparePerson context:m_peopleInfo];
    
    
    for (int i = 0; i < [allFriends count]; ++i) {
		long uid = [[allFriends objectAtIndex:i] longValue];
		Person *person = [m_friendInfo objectForKey:[NSNumber numberWithLong:uid]];
		NSString *personName = [person.name lowercaseString];
		if ([lowerText length] == 0 || [personName rangeOfString:lowerText].location != NSNotFound) {
			[m_visibleFriendsList addObject:[NSNumber numberWithLong:[person.facebookId longLongValue]]];
		}
	}
   	[m_visibleFriendsList sortUsingFunction:comparePerson context:m_friendInfo];
    

    
}

- (void)refreshPeople {
}

- (void)setPeople:(NSMutableDictionary *)people andFriends:(NSMutableDictionary *)friend {
	[m_peopleInfo release];
	m_peopleInfo = [people retain];
    
	[m_visiblePeopleList removeAllObjects];
	[m_visiblePeopleList setArray:[m_peopleInfo allKeys]];
	[m_visiblePeopleList sortUsingFunction:comparePerson context:m_peopleInfo];
    
    [m_friendInfo release];
    m_friendInfo = [friend retain];
    
    [m_visibleFriendsList removeAllObjects];
    [m_visibleFriendsList setArray:[m_friendInfo allKeys]]; //visible friends = array of keys of m_friendInfo
	[m_visibleFriendsList sortUsingFunction:comparePerson context:m_friendInfo];
    
	[m_swithSelectedButton setTitle:@"Selected (0)" forSegmentAtIndex:1];
	[m_swithSelectedButton setEnabled:NO forSegmentAtIndex:1];
    
    [m_customMessageLabel setEnabled:NO];
    [m_customMessageLabel setTextColor:[UIColor lightGrayColor]];
    [m_customMessageLabel invalidateIntrinsicContentSize];
	[self.tableView reloadData];
	[self refreshImages];
}

- (int)cellStyle {
	return UITableViewCellStyleDefault;
}

- (void)loadImage:(int)uid {
	// To be overridden
}

//- (void)setImage:(UIImage *)image withId:(int)uid {
//	[m_imageCache setObject:image forKey:[NSNumber numberWithInt:uid]];
//	[self.tableView reloadData];
//}

- (IBAction)inviteButtonClicked:(id)sender {
	UISegmentedControl *inviteButton = (UISegmentedControl *)sender;
	[self switchSelect:inviteButton.tag];
    NSLog(@"CLICK!");
}

- (void)switchSelect:(int)index {
	[m_searchBar resignFirstResponder];
	Person *person = [m_peopleInfo objectForKey:[m_visiblePeopleList objectAtIndex:index]];
	person.selected = !person.selected;
	int selectedCount = [[self selectedIds] count];
	[m_swithSelectedButton setTitle:[NSString stringWithFormat:@"Selected (%d)", selectedCount] forSegmentAtIndex:1];
    
    if (selectedCount > 0) {
        [m_customMessageLabel setEnabled:YES];
        [m_customMessageLabel setTextColor:[UIColor colorWithRed:23.0f/255.0f green:68.0f/255.0f blue:117.0f/255.0f alpha:1.0]];
    } else {
        [m_customMessageLabel setEnabled:NO];
        [m_customMessageLabel setTextColor:[UIColor lightGrayColor]];
    }
    
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
    
    [m_customMessageLabel setEnabled:NO];
    [m_customMessageLabel setTextColor:[UIColor lightGrayColor]];
    [m_customMessageLabel invalidateIntrinsicContentSize];
    
	[self showAll];
}

- (void)clearPeople {
	[m_peopleInfo removeAllObjects];
	[m_visiblePeopleList removeAllObjects];
	[self.tableView reloadData];
	[self clearImageCache];
}

- (void)showAll {
	m_swithSelectedButton.selectedSegmentIndex = 0;
	[self filterWithText:[m_searchBar text]];
	[self.tableView reloadData];
	[self refreshImages];
}

- (void)showSelected {
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

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568){
        invitationController = [[[InvitationController alloc] initWithNibName:@"InvitationController_i5" bundle:nil] autorelease];
    }else{
        invitationController = [[[InvitationController alloc] initWithNibName:@"InvitationController" bundle:nil] autorelease];
    }
    
    NSArray *selectedIds = [self selectedIds];
    NSMutableArray *selectedPeople = [[[NSMutableArray alloc] init] autorelease];
   

    for (int i = 0; i < [selectedIds count]; ++i) {
		
        long uid = [[selectedIds objectAtIndex:i] longValue];
		
        Person *person = [m_peopleInfo objectForKey:[NSNumber numberWithLong:uid]];
        
        [selectedPeople addObject:person];

	}
    
    invitationController.selectedPeople = selectedPeople;
    
	DyfocusUINavigationController *navCtlr = [[[DyfocusUINavigationController alloc] initWithRootViewController:invitationController] autorelease];
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
    [self.tableView reloadData];
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
	[self.navigationController setNavigationBarHidden:YES animated:YES];
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
    if (m_customMessageLabel.enabled) {
        [self personalizeMessage];
        [m_customMessageLabel setTextColor:[UIColor colorWithRed:23.0f/255.0f green:68.0f/255.0f blue:117.0f/255.0f alpha:1.0]];
    }
}

- (void)customMessageButtonTouchDown {
    if (m_customMessageLabel.enabled) {
        m_customMessageLabel.textColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:150.0/255 alpha:1.0];
    }
}

- (void)customMessageButtonTouchUpOutside {
    if (m_customMessageLabel.enabled) {
        [m_customMessageLabel setTextColor:[UIColor colorWithRed:23.0f/255.0f green:68.0f/255.0f blue:117.0f/255.0f alpha:1.0]];
    }
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

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
