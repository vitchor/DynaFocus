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
    
    IBOutlet UILabel *shareLabel;
    IBOutlet UISwitch *facebookSwitch;
    IBOutlet UIView *activityIndicator;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UITextView *commentField;
    IBOutlet UILabel *placeHolderLabel;
    IBOutlet UILabel *titleMessage;

    FBSession *facebook;
    ASIFormDataRequest *request;
    NSMutableArray *frames;
    NSMutableArray *focalPoints;
    NSString *fofName;
    NSString *fofUserFbId;
    UIBarButtonItem *backButton;
    
}

-(void) facebookError;
-(IBAction) toggleEnabledForSwitch: (id) sender;

@property(nonatomic,retain) IBOutlet UISwitch *facebookSwitch;
@property(nonatomic,retain) IBOutlet UIView *activityIndicator;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic,retain) IBOutlet UITextView *commentField;
@property(nonatomic,retain) IBOutlet UILabel *titleMessage;

@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *focalPoints;
@property(nonatomic,retain) UIBarButtonItem *backButton;
@property(nonatomic,retain) NSString *fofName;
@property(nonatomic,retain) NSString *fofUserFbId;

@end
