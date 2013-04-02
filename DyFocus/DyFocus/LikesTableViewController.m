//
//  LikesTableViewController.m
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "LikesTableViewController.h"
#import "AppDelegate.h"
#import "JSON.h"

@interface LikesTableViewController ()

@end

@implementation LikesTableViewController

@synthesize likesTableView, likesArray;

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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [likesArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LikesTableViewCell *cell;
    
    //NSString *cellId = [NSString stringWithFormat:@"FOFTableCell", indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:@"LikesTableViewCell"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"LikesTableViewCell" owner:self options:nil];
        
        // Load the top-level objects from the custom cell XIB.
        cell = [topLevelObjects objectAtIndex:0];
        
    }
    [cell refreshWithLike:[likesArray objectAtIndex:indexPath.row]];
    return cell;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [likesTableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//
//#pragma mark -
//#pragma mark Table Data Source Methods
//- (NSInteger)tableView:(UITableView *)tableView
// numberOfRowsInSection:(NSInteger)section {
//    
//    if (notifications && [notifications count] != 0) {
//        isTableEmpty = NO;
//        return [notifications count];
//    } else {
//        isTableEmpty = YES;
//        return 1;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView
//		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    if (isTableEmpty) {
//        UITableViewCell *cell;
//        
//        NSString *cellId = @"empty";
//        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        
//        if (cell == nil) {
//            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
//        }
//        
//        cell.textLabel.text = @"No Likes were found";
//        cell.textLabel.textColor = [UIColor lightGrayColor];
//        cell.textLabel.textAlignment = UITextAlignmentCenter;
//        cell.textLabel.font = [UIFont systemFontOfSize:20];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryView = nil;
//        cell.imageView.image = nil;
//        
//        return cell;
//        
//    } else {
//        
//        LikesTableViewCell *cell;
//        
//        
//        NSString *cellId = @"LikesTableViewCell";
//        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        if (cell == nil) {
//            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"LikesTableViewCell" owner:self options:nil];
//            
//            // Load the top-level objects from the custom cell XIB.
//            cell = [topLevelObjects objectAtIndex:0];
//            
//        }
//        
//        Notification *notification = (Notification *) [notifications objectAtIndex:indexPath.row];
//        
//        [cell refreshWithNotification:notification];
//        
//        return cell;
//    }
//    
//    
//}
//
//-(void)refreshImages {
//    if (!isTableEmpty) {
//		NSArray *visibleCells = [notificationsTableView visibleCells];
//		if (visibleCells) {
//			NSArray *visibleCellsCopy = [[NSArray alloc] initWithArray:visibleCells];
//			for (LikesTableViewCell *cell in visibleCellsCopy) {
//                [cell loadImage];
//			}
//			[visibleCellsCopy release];
//		}
//	}
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 63;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	[self refreshImages];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	if (decelerate == NO) {
//		[self refreshImages];
//	}
//}
//
//#pragma mark -
//#pragma mark Table Delegate Methods
//- (void)tableView:(UITableView *)tableView
//didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    Notification *notification = [notifications objectAtIndex:indexPath.row];
//    
//    if (notification.m_triggerType == NOTIFICATION_LIKED_FOF || notification.m_triggerType == NOTIFICATION_COMMENTED_FOF) {
//     
//        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//        
//        for (FOF *fof in delegate.userFofArray) {
//         
//            if ([fof.m_id intValue] == notification.m_triggerId) {
//                
//                FOFTableController *tableController = [[FOFTableController alloc] init];
//                
//                NSMutableArray *array = [NSMutableArray arrayWithObject:fof];
//                tableController.FOFArray = array;
//                tableController.shouldHideNavigationBar = NO;
//                
//                tableController.navigationItem.title = @"Likes";
//                tableController.hidesBottomBarWhenPushed = YES;
//                
//                [self.navigationController pushViewController:tableController animated:true];
//                [self.navigationController setNavigationBarHidden:NO animated:TRUE];
//                
//                break;
//            }
//        }
//    }
//}
//
//-(void)viewDidDisappear:(BOOL)animated {
//    
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//
//    [delegate clearNotifications];
//    [super viewDidDisappear:animated];
//}


@end
