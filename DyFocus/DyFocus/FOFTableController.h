//
//  FOFTableController.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FOFTableController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *m_tableView;
    NSArray *FOFArray;
    NSMutableDictionary *cellHeightDictionary;
    BOOL shouldHideNavigationBar;
}

@property (nonatomic, retain) IBOutlet UITableView *m_tableView;
@property (nonatomic, retain) IBOutlet NSArray *FOFArray;
@property (nonatomic, readwrite) BOOL shouldHideNavigationBar;

-(void) addNewCellHeight:(float)height atRow:(int)row;

@end
