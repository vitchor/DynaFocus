//
//  FriendProfileController.h
//  DyFocus
//
//  Created by Cássio Marcos Goulart on 24/01/13.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FriendProfileController : UIViewController {
    FBSession *facebook;
    NSString *userName;
    IBOutlet UIButton *viewPicturesButton;
}

@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIView *dyfocusProfileView;
@property (strong, nonatomic) IBOutlet UIButton *viewPicturesButton;

@end