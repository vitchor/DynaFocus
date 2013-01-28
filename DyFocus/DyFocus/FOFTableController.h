//
//  FOFTableController.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface FOFTableController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *m_tableView;
    NSArray *FOFArray;
    NSMutableDictionary *cellHeightDictionary;
    BOOL shouldHideNavigationBar;
    EGORefreshTableHeaderView *refreshHeaderView;
    
    NSString *refreshString;
    
    BOOL _reloading;
}

@property (nonatomic, retain) IBOutlet UITableView *m_tableView;
@property (nonatomic, retain) IBOutlet NSArray *FOFArray;
@property (nonatomic, readwrite) BOOL shouldHideNavigationBar;
@property (nonatomic, readwrite) NSString *refreshString;

-(void) addNewCellHeight:(float)height atRow:(int)row;

-(void) refreshWithAction:(BOOL)isAction;

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;


@end
