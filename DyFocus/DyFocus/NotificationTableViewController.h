//
//  NotificationTableViewController.h
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationTableViewCell.h"

@interface NotificationTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>  {
    IBOutlet UITableView *notificationsTableView;
    NSMutableArray *notifications;
    bool isTableEmpty;
}

@property (nonatomic,retain) IBOutlet UITableView *notificationsTableView;
@property (nonatomic,retain) NSArray *notifications;
@end
