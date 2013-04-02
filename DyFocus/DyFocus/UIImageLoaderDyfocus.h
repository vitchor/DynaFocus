//
//  UIImageLoaderDyfocus.h
//  DyFocus
//
//  Created by mhss on 3/9/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDyfocusImage.h"

@interface UIImageLoaderDyfocus : NSObject{
    //variables
    UIDyfocusImage *myPicture;
    UIDyfocusImage *bufferPic;
}
//    @property...
// public:
+ (id) sharedUIImageLoader;

- (void) loadProfilePicture:(NSString *)facebookId andProfileImage:(UIImageView *)profileImage;
- (UIImage *) loadAnyProfilePicture:(UIImageView *)profileImageView andFacebookId:(NSString *)facebookId;
- (UIImage *) loadMyProfilePicture:(UIImageView *)profileImageView;
- (void)loadUserProfileController:(NSString *)facebookId andUserName:(NSString *)userName andNavigationController:(UINavigationController *)navController;
- (void) loadListProfilePicture:(NSString *)facebookId andFOFId:(NSString *)fofId andImageView:(UIImageView*)imageUserPicture;
-(void) loadCommentProfilePicture:(NSString *)userId andImageView:(UIImageView *)imageUserPicture;
-(void) loadPeopleProfilePicture:(NSString*)facebookId andImageCache:(NSMutableDictionary *)m_imageCache andUid:(int)uid andTableView: (UITableView*)tableView;
-(void) cashProfilePicture;



//private:


@end
