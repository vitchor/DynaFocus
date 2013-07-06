//
//  SharingController.h
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "LoadView.h"
#import "UIImage+fixOrientation.h"

#define MAX_LENGTH 210

@interface SharingController : UIViewController <UITextViewDelegate>{
    
    IBOutlet UIView *activityIndicator;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UITextView *commentField;
    IBOutlet UILabel *placeHolderLabel;
    IBOutlet UILabel *titleWithFb;
    IBOutlet UILabel *titleWithoutFb;
    IBOutlet UILabel *shareOnFbLabel;
    IBOutlet UISwitch *facebookSwitch;
    IBOutlet UISwitch *isPrivate;
    
    ASIFormDataRequest *request;
}

@property(nonatomic,retain) NSString *fofName;
@property(nonatomic,retain) NSMutableArray *frames;
@property(nonatomic,retain) NSMutableArray *focalPoints;

@end
