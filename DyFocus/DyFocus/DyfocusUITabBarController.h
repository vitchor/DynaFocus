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
}


@property(nonatomic,retain) WebViewController *feedWebController;
@property(nonatomic,retain) WebViewController *featuredWebController;

@end
