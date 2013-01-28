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

}

-(id) initWithFOFArray:(NSArray *)FOFArray andUrl:(NSString *)refreshUrl;

@property(nonatomic, retain) FOFTableController *tableController;

@end
