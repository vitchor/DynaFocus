//
//  SharingController.h
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SharingController : UIViewController {

    IBOutlet UISwitch *facebookSwitch;
    FBSession *facebook;
    IBOutlet UIView *activityIndicator;
}


@property(nonatomic,retain) IBOutlet UISwitch *facebookSwitch;
@property(nonatomic,retain) IBOutlet UIView *activityIndicator;

@end
