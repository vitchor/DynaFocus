//
//  SplashScreenController.h
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashScreenController : UIViewController {
    
    IBOutlet UIActivityIndicatorView *spinner;
}

@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;

@end
