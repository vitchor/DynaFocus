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
    IBOutlet UIView *loadingView;
    NSMutableArray *FOFArray;
    NSMutableDictionary *cellHeightDictionary;
    BOOL shouldHideNavigationBar;
    EGORefreshTableHeaderView *refreshHeaderView;
    
    NSString *refreshString;
    
    long userId;
    
    BOOL _reloading;
    BOOL m_isFOFTableEmpty;
}

@property (nonatomic,retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UITableView *m_tableView;
@property (nonatomic, retain) IBOutlet NSMutableArray *FOFArray;
@property (nonatomic, readwrite) BOOL shouldHideNavigationBar;
@property (nonatomic, readwrite) NSString *refreshString;
@property (nonatomic, readwrite) long userId;
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

-(void) addNewCellHeight:(float)height atRow:(int)row;
-(void) refreshWithAction:(BOOL)isAction;
-(void)reloadTableViewDataSource;
-(void)dataSourceDidFinishLoadingNewData;
-(int)cellStyle;


@end
