//
//  FOFTableController.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSON.h"
#import "LoadView.h"
#import "EGORefreshTableHeaderView.h"

@interface FOFTableController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
//    long userId;
    float lastOffset;
    
    BOOL _reloading;
    BOOL m_isFOFTableEmpty;
    BOOL withHeader;
//    BOOL shouldHideNavigationBar;
//    BOOL shouldHideNavigationBarWhenScrolling;
//    BOOL shouldHideTabBarWhenScrolling;
//    BOOL shouldShowSegmentedBar;
   
//    IBOutlet UITableView *m_tableView;
//    IBOutlet UIView *loadingView;
   
    NSString *refreshString;
    NSMutableArray *FOFArray;
    NSMutableDictionary *cellHeightDictionary;
    
//    EGORefreshTableHeaderView *refreshHeaderView;
    
}

@property (nonatomic, readwrite) long userId;

@property(assign,getter=isReloading) BOOL reloading;

@property (nonatomic, readwrite) BOOL shouldHideNavigationBar;
@property (nonatomic, readwrite) BOOL shouldHideNavigationBarWhenScrolling;
@property (nonatomic, readwrite) BOOL shouldHideTabBarWhenScrolling;
@property (nonatomic, readwrite) BOOL shouldShowSegmentedBar;

@property (nonatomic,retain)  IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UITableView *m_tableView;

@property (nonatomic, readwrite) NSString *refreshString;
@property (nonatomic, retain) NSMutableArray *FOFArray;

@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;


-(void) addNewCellHeight:(float)height atRow:(int)row;
-(void) refreshFOFArrayWithHeader:(BOOL)isWithHeader;
-(void) reloadTableViewDataSource;
-(void) dataSourceDidFinishLoadingNewData;
-(int)  cellStyle;

@end
