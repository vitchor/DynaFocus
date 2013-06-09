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
}

@property(nonatomic, retain) UIDyfocusImage *myPicture;

// Singleton:
+ (id) sharedUIImageLoader;

// Called from many classes. All of them also use this class to load users images:
- (void)loadFriendControllerWithFaceId:(NSString *)facebookId andUserName:(NSString *)userName andNavigationController:(UINavigationController *)navController;

// Generic Method to load any user picture:
- (void) loadPictureWithFaceId:(NSString *)facebookId andImageView:(UIImageView *)profileImage andIsSmall:(BOOL)isSmall;
- (void) cashProfilePicture; //Cash user picture when signing in

// I couldn't modularize the below methods:
- (void) loadFofTableCellUserPicture:(NSString *)facebookId andFOFId:(NSString *)fofId andImageView:(UIImageView*)imageUserPicture;
- (void) loadFriendTabPicsWithFaceId:(NSString*)facebookId andImageCache:(NSMutableDictionary *)m_imageCache andUid:(int)uid andTableView: (UITableView*)tableView;



@end
