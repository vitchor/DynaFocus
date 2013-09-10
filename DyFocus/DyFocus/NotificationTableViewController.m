//
//  NotificationTableViewController.m
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "NotificationTableViewController.h"

@implementation NotificationTableViewController

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
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"NotificationTableViewController.viewDidAppear"];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [notificationsTableView setDataSource:self];
    [notificationsTableView setDelegate:self];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    notifications = delegate.notificationsArray;
    
    
    NSString *requestUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/user_read_notification/",dyfocus_url] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];

    if (notifications && [notifications count] > 0 ) {
        Notification *notification = [notifications objectAtIndex:0];
        
        NSString *notificationId = [NSString stringWithFormat:@"%@", notification.m_notificationId];
        
        [jsonRequestObject setObject:notificationId forKey:@"notification_id"];
        
    } else {
        [jsonRequestObject setObject:@"0" forKey:@"notification_id"];
    }
    
    NSString *userId = [NSString stringWithFormat:@"%ld", delegate.myself.uid];
    
    NSLog(@"USER ID %@", userId);
    
    [jsonRequestObject setObject:userId forKey:@"user_id"];
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
                                   
                                   NSLog(@"lalalal %@", stringReply);
                                   
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
                                       [self refreshImages];
                               
                                       //Everything is updated on our side! Let's mark everything as read!
                                       
                                       if (notifications && [notifications count] != 0) {
                                           
                                           NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
                                           NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
                                           Notification *notification =[notifications objectAtIndex:0];
                                           [jsonRequestObject setObject:[NSString stringWithFormat:@"%@",notification.m_notificationId] forKey:@"notification_id"];
                                           
                                           NSString *userId = [NSString stringWithFormat:@"ld", delegate.myself.uid];
                                           [jsonRequestObject setObject:userId forKey:@"user_id"];
                                           
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
        
        
        NSString *cellId = @"NotificationTableViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"NotificationTableViewCell" owner:self options:nil];
            
            // Load the top-level objects from the custom cell XIB.
            cell = [topLevelObjects objectAtIndex:0];
            
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
                
                [self showFofInTable:fof];
                
                break;
            }
        }
    } else if (notification.m_triggerType == NOTIFICATION_FOLLOWED_YOU) {
    
        ProfileController *profileController = [[ProfileController alloc] initWithUserId:notification.m_triggerId];

        profileController.hidesBottomBarWhenPushed = YES;
    
        [self.navigationController pushViewController:profileController animated:YES];
        [profileController release];
        
    } else if (notification.m_triggerType == NOTIFICATION_COMMENTED_ON_COMMENTED_FOF || notification.m_triggerType == NOTIFICATION_COMMENTED_ON_LIKED_FOF) {
        
        [LoadView loadViewOnView:self.view withText:@"Loading..."];
        
        NSString *url = [[[NSString alloc] initWithFormat:@"%@/uploader/get_fof_json/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        
        NSString *fofId = [NSString stringWithFormat:@"%d",notification.m_triggerId];
        [jsonRequestObject setObject:fofId forKey:@"fof_id"];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSString *user_id = [NSString stringWithFormat:@"%ld",delegate.myself.uid];
        [jsonRequestObject setObject:user_id forKey:@"user_id"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   [LoadView fadeAndRemoveFromView:self.view];
                                   
                                   if (!error && data) {
                                       NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                       
                                       NSLog(@"stringReply: %@",stringReply);
                                       
                                       NSDictionary *jsonValues = [stringReply JSONValue];
                                       
                                       NSDictionary *jsonFof = [jsonValues valueForKey:@"fof"];
                                       
                                       FOF *fof = [[FOF fofFromJSON:jsonFof] autorelease];
                                           
                                       [self showFofInTable:fof];
                                       
                                   } else {
                                       [self showOkAlertWithMessage:@"Please try again later." andTitle:@"Connection Error"];
                                   }
                               }];
        
    }
    
    
}

-(void) showFofInTable:(FOF *)fof {
    FOFTableController *tableController = [[FOFTableController alloc] init];
    
    NSMutableArray *array = [NSMutableArray arrayWithObject:fof];
    tableController.FOFArray = array;
    tableController.shouldHideNavigationBar = NO;
    
    tableController.navigationItem.title = @"Notification";
    tableController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tableController animated:true];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    [tableController release];
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

-(void)viewDidDisappear:(BOOL)animated {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

    [delegate clearNotifications];
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    [notificationsTableView release];
    [notifications release];
    
    [super dealloc];
}


@end
