//
//  NotificationTableViewController.h
//  DyFocus
//
//  Created by Victor on 3/8/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSON.h"

#import "LoadView.h"
#import "AppDelegate.h"
#import "NotificationTableViewCell.h"


@interface NotificationTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>  {

    bool isTableEmpty;
}

@property (nonatomic, retain) UITableView *notificationsTableView;
@property (nonatomic, retain) NSMutableArray *notifications;

@end
