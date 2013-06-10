//
//  FOFTableNavigationController.h
//  DyFocus
//
//  Created by Victor on 1/27/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FOFTableController.h"

@interface FOFTableNavigationController : UINavigationController {
    
    FOFTableController *tableController;
    
    UISegmentedControl *segmentedControl;

    NSArray *trendingFOFArray;
    NSString *refreshTrendingUrl;
}

-(id) initWithFOFArray:(NSArray *)FOFArray andUrl:(NSString *)refreshUrl;
-(id) initWithTopRatedFOFArray:(NSArray *)topRatedFOFArray andTopRatedUrl:(NSString *)refreshTopRatedUrl andTrendingFOFArray:(NSArray *)trendingFOFArray andTrendingUrl:(NSString *)refreshTrendingUrl;

-(void) setSegmentedControlHidden:(BOOL)hidden;

@property(nonatomic, retain) FOFTableController *tableController;

@end
