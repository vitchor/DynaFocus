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
    
    float lastOffset;
    
    BOOL isReloading;
    BOOL m_isFOFTableEmpty;
    BOOL withHeader;

    UIView *loadingView;
    UITableView *m_tableView;
    NSMutableDictionary *cellHeightDictionary;
    
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (nonatomic, readwrite) long userId;

@property (nonatomic, readwrite) BOOL shouldHideNavigationBar;
@property (nonatomic, readwrite) BOOL shouldHideNavigationBarWhenScrolling;
@property (nonatomic, readwrite) BOOL shouldHideTabBarWhenScrolling;
@property (nonatomic, readwrite) BOOL shouldShowSegmentedBar;

@property (nonatomic, readwrite) NSString *refreshString;
@property (nonatomic, retain) NSMutableArray *FOFArray;

@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

-(int)  cellStyle;
-(void) addNewCellHeight:(float)height atRow:(int)row;
-(void) refreshFOFArrayWithHeader:(BOOL)isWithHeader;

@end
