//
//  LikesTableViewController.h
//  DyFocus
//
//  Created by Marcelo Salloum on 3/31/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSON.h"

#import "AppDelegate.h"
#import "LikesTableViewCell.h"
#import "UIImageLoaderDyfocus.h"

@interface LikesTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{

}

@property (nonatomic,retain) NSMutableArray *likesArray;
@property (nonatomic,retain) IBOutlet UITableView *likesTableView;

@end
