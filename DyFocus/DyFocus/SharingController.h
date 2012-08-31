//
//  SharingController.h
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ASIFormDataRequest.h"

@interface SharingController : UIViewController {

    IBOutlet UISwitch *facebookSwitch;
    FBSession *facebook;
    IBOutlet UIView *activityIndicator;
    IBOutlet UIActivityIndicatorView *spinner;
    NSMutableArray *frames;
    NSMutableArray *focalPoints;
    ASIFormDataRequest *request;
    NSString *fofName;
}

-(void) requestUserInfo:(FBSession *)session;
-(void) facebookError;

@property(nonatomic,retain) IBOutlet UISwitch *facebookSwitch;
@property(nonatomic,retain) IBOutlet UIView *activityIndicator;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;

@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *focalPoints;

@end
