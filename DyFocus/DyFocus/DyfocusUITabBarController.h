//
//  DyfocusUITabBarController.h
//  DyFocus
//
//  Created by Victor Oliveira on 8/28/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
@interface DyfocusUITabBarController : UITabBarController <UITabBarControllerDelegate> {

    WebViewController *feedWebController;
    WebViewController *featuredWebController;
    int lastOrientation;
    int lastControllerIndex;
    int actualControllerIndex;    
}


@property(nonatomic,retain) WebViewController *feedWebController;
@property(nonatomic,retain) WebViewController *featuredWebController;
@property(nonatomic,readwrite) int lastControllerIndex;
@property(nonatomic,readwrite) int actualControllerIndex;

@end
