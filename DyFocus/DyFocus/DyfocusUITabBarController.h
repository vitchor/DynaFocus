//
//  DyfocusUITabBarController.h
//  DyFocus
//
//  Created by Victor Oliveira on 8/28/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DyfocusUITabBarController : UITabBarController <UITabBarControllerDelegate> {

    int lastOrientation;
    int lastControllerIndex;
    int actualControllerIndex;    
}

@property(nonatomic,readwrite) int lastControllerIndex;
@property(nonatomic,readwrite) int actualControllerIndex;

@end
