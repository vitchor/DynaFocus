//
//  LikesTableViewController.m
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "LikesTableViewController.h"

@implementation LikesTableViewController

@synthesize likesArray, likesTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Likes";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.navigationItem.title = @"Likes";
        self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self refreshImages];
    
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    [delegate logEvent:@"LikesTableViewController.viewDidAppear"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath* selection = [self.likesTableView indexPathForSelectedRow];
    if (selection) {
        [self.likesTableView deselectRowAtIndexPath:selection animated:YES];
    }
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    Like *like = [self.likesArray objectAtIndex:indexPath.row];
        
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

    ProfileController *profileController = nil;
    
    Person *person;
    if(like.m_userId == delegate.myself.uid){
        person = delegate.myself;
    }else{
        person = [delegate getUserWithId:like.m_userId];
    }

    if (person) {
        // Person exists, so it's being followed.
        NSMutableArray *userFOFArray = [delegate FOFsFromUser:person.uid];
        profileController = [[ProfileController alloc] initWithPerson:person personFOFArray:userFOFArray];
    } else {
        // Person is not being followed, there's no information we can get.
        profileController = [[ProfileController alloc] initWithUserId:like.m_userId];
    }

    profileController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:profileController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    [profileController release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.likesArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LikesTableViewCell *cell;
    
    //NSString *cellId = [NSString stringWithFormat:@"FOFTableCell", indexPath.row];
    //NSString *cellId = [NSString stringWithFormat:@"FOFTableCell_free", indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:@"LikesTableViewCell"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"LikesTableViewCell" owner:self options:nil];
        
        // Load the top-level objects from the custom cell XIB.
        cell = [topLevelObjects objectAtIndex:0];
        
    }
    [cell refreshWithLike:[self.likesArray objectAtIndex:indexPath.row]];
    return cell;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.likesTableView setDataSource:self];
    [self.likesTableView setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [likesArray release];
    [likesTableView release];
    
    [super dealloc];
}

@end
