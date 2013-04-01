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
    IBOutlet NSString *userName;
    IBOutlet NSString *userFacebookId;
    IBOutlet UIButton *viewPicturesButton;
    IBOutlet UIButton *follow;
    IBOutlet UIButton *unfollow;
}

- (void) showPictures;
- (void) clearCurrentUser;

@property (strong, nonatomic) IBOutlet NSString *userName;
@property (strong, nonatomic) IBOutlet NSString *userFacebookId;

@property (strong, nonatomic) IBOutlet UILabel *followingLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;


@property (strong, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIView *dyfocusProfileView;
@property (strong, nonatomic) IBOutlet UIButton *viewPicturesButton;

@property (strong, nonatomic) IBOutlet UIButton *follow;
@property (strong, nonatomic) IBOutlet UIButton *unfollow;

@end