//
//  NotificationTableViewController.m
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "NotificationTableViewController.h"
#import "AppDelegate.h"
#import "JSON.h"

@interface NotificationTableViewController ()

@end

@implementation NotificationTableViewController

@synthesize notificationsTableView, notifications;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self refreshImages];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [notificationsTableView setDataSource:self];
    [notificationsTableView setDelegate:self];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    self.notifications = delegate.notificationsArray;
    
    
    NSString *requestUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/read_notification/",dyfocus_url] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];

    if (notifications && [notifications count] > 0 ) {
        Notification *notification =[notifications objectAtIndex:0];
        [jsonRequestObject setObject:notification.m_notificationId forKey:@"notification_id"];
    } else {
        [jsonRequestObject setObject:@"0" forKey:@"notification_id"];
    }
    
    [jsonRequestObject setObject:[delegate.myself objectForKey:@"id"] forKey:@"user_id"];
    [jsonRequestObject setObject:@"1" forKey:@"read_all"];
    
    NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {
                                   
                                   NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                   
                                   
                                   NSDictionary *jsonValues = [stringReply JSONValue];
                                   
                                   
                                   NSDictionary * jsonNotifications = [jsonValues valueForKey:@"notification_list"];
                                   
                                   if (jsonNotifications && [jsonNotifications count] > 0) {
                                       
                                       [notifications removeAllObjects];
                                       
                                       for (int i = 0; i < [jsonNotifications count]; i++) {
                                           
                                           NSDictionary *jsonNotification = [jsonNotifications objectAtIndex:i];
                                           
                                           Notification *notification = [Notification notificationFromJSON:jsonNotification];
                                           
                                           [notifications addObject:notification];
                                           
                                       }
                                       
                                       [notificationsTableView reloadData];
                               
                                       //Everything is updated on our side! Let's mark everything as read!
                                       
                                       if (notifications && [notifications count] != 0) {
                                           
                                           NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
                                           NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
                                           Notification *notification =[notifications objectAtIndex:0];
                                           [jsonRequestObject setObject:notification.m_notificationId forKey:@"notification_id"];
                                           [jsonRequestObject setObject:[delegate.myself objectForKey:@"id"] forKey:@"user_id"];
                                           [jsonRequestObject setObject:@"1" forKey:@"read_all"];
                                           NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
                                           [request setHTTPMethod:@"POST"];
                                           [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                                                                  json] dataUsingEncoding:NSUTF8StringEncoding]];
                                           
                                           [NSURLConnection sendAsynchronousRequest:request
                                                                              queue:[NSOperationQueue mainQueue]
                                                                  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                                      if(!error && data) {
                                                                          NSLog(@"NICE!");
                                                                          [delegate clearNotifications];
                                                                      } else {
                                                                          NSLog(@"ERROR");
                                                                      }}];
                                        }

                                   } else if (jsonNotifications && [jsonNotifications count] == 0 ) {
                                       [delegate clearNotifications];
                                       //[notificationsTableView reloadData];
                                       
                                   }
     
                               }
                           }];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if (notifications && [notifications count] != 0) {
        isTableEmpty = NO;
        return [notifications count];
    } else {
        isTableEmpty = YES;
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (isTableEmpty) {
        UITableViewCell *cell;
        
        NSString *cellId = @"empty";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
        }
        
        cell.textLabel.text = @"No notifications were found";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:20];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        cell.imageView.image = nil;
        
        return cell;
        
    } else {
        
        NotificationTableViewCell *cell;
        
        
        NSString *cellId = [NSString stringWithFormat:@"0_%d", indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"NotificationTableViewCell" owner:self options:nil];
            
            for(id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[NotificationTableViewCell class]]) {
                    cell = (NotificationTableViewCell *)currentObject;
                    //cell.commentController = self;
                    break;
                }
            }
            
        }
        
        Notification *notification = (Notification *) [notifications objectAtIndex:indexPath.row];
        
        [cell refreshWithNotification:notification];
        
        return cell;
    }
    
    
}

-(void)refreshImages {
    if (!isTableEmpty) {
		NSArray *visibleCells = [notificationsTableView visibleCells];
		if (visibleCells) {
			NSArray *visibleCellsCopy = [[NSArray alloc] initWithArray:visibleCells];
			for (NotificationTableViewCell *cell in visibleCellsCopy) {
                [cell loadImage];
			}
			[visibleCellsCopy release];
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self refreshImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate == NO) {
		[self refreshImages];
	}
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Notification *notification = [notifications objectAtIndex:indexPath.row];
    
    if (notification.m_triggerType == NOTIFICATION_LIKED_FOF || notification.m_triggerType == NOTIFICATION_COMMENTED_FOF) {
     
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        for (FOF *fof in delegate.userFofArray) {
         
            if ([fof.m_id intValue] == notification.m_triggerId) {
                
                FOFTableController *tableController = [[FOFTableController alloc] init];
                
                NSMutableArray *array = [NSMutableArray arrayWithObject:fof];
                tableController.FOFArray = array;
                tableController.shouldHideNavigationBar = NO;
                
                tableController.navigationItem.title = @"Notification";
                tableController.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:tableController animated:true];
                [self.navigationController setNavigationBarHidden:NO animated:TRUE];
                
                break;
            }
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

    [delegate clearNotifications];
    [super viewDidDisappear:animated];
}


@end
