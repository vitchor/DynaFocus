//
//  ProfileController.h
//  DyFocus
//
//  Created by Alexandre Cordeiro on 8/30/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ProfileController : UIViewController {
    FBSession *facebook;
    NSString *userName;
    IBOutlet UIButton *myPicturesButton;
    IBOutlet UIImageView *userPicture;
}

- (void)logout;

//@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UIImageView *userPicture;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIView *dyfocusProfileView;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *myPicturesButton;

@end