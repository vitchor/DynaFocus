//
//  LikesTableViewController.h
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikesTableViewCell.h"

@interface LikesTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>  {
    IBOutlet UITableView *notificationsTableView;
    NSMutableArray *notifications;
    bool isTableEmpty;
}

@property (nonatomic,retain) IBOutlet UITableView *notificationsTableView;
@property (nonatomic,retain) NSArray *notifications;
@end
