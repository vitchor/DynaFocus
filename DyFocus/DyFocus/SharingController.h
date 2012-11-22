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
    IBOutlet UIView *facebookLoginView;
    IBOutlet UIButton *continueToFacebookLoginButton;
    IBOutlet UIButton *cancelFacebookLoginButton;
    IBOutlet UIView *activityIndicator;
    IBOutlet UIActivityIndicatorView *spinner;
    
    FBSession *facebook;
    ASIFormDataRequest *request;
    NSMutableArray *frames;
    NSMutableArray *focalPoints;
    NSString *fofName;
    
    
}

-(void) requestUserInfo:(FBSession *)session withTag:(int)tag;;
-(void) facebookError;

@property(nonatomic,retain) IBOutlet UISwitch *facebookSwitch;
@property(nonatomic,retain) IBOutlet UIView *activityIndicator;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;

@property(nonatomic,retain)  IBOutlet UIView *facebookLoginView;
@property(nonatomic,retain)  IBOutlet UIButton *continueToFacebookLoginButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelFacebookLoginButton;

@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *focalPoints;

@end
