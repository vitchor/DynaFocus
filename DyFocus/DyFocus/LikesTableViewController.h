//
//  LikesTableViewController.h
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikesTableViewCell.h"

@interface LikesTableViewController : UIViewController <UITableViewDataSource>  {
    IBOutlet UITableView *likesTableView;
    NSMutableArray *likesArray;
    bool isTableEmpty;
}

@property (nonatomic,retain) IBOutlet UITableView *likesTableView;
@property (nonatomic,retain) NSMutableArray *likesArray;
@end
