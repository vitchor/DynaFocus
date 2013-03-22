//
//  UIImageLoaderDyfocus.m
//  DyFocus
//
//  Created by mhss on 3/9/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "UIImageLoaderDyfocus.h"
#import "AppDelegate.h"
#import "NSDyfocusURLRequest.h"

@implementation UIImageLoaderDyfocus
//@syntethize anyProperty

// Singleton:
+(id)sharedUIImageLoader{
    static UIImageLoaderDyfocus *sharedMyUILoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyUILoader = [[self alloc] init];
    });
    return sharedMyUILoader;
}

// Singleton
- (id)init {
    if (self = [super init]) {
//        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
    }
    return self;
}

// Singleton
- (void)dealloc {
    [myPicture dealloc];
    [bufferPic dealloc];
    [super dealloc];
    // Should never be called, but just here for clarity really.
}

//Load Profile Picture, usually called from ProfileController or FriendProfileController
- (void) loadProfilePicture:(NSString *)facebookId andProfileImage:(UIImageView *)profileImage{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([facebookId isEqualToString:appDelegate.myself.facebookId]){
        [self loadMyProfilePicture:profileImage];
    }else{
        [self loadAnyProfilePicture:profileImage andFacebookId:facebookId];
    }
}

// Loads profile picture for commentCell. It does a process slightly different from the one used in loadProfilePicture function
-(void) loadCommentProfilePicture:(NSString *)userId andImageView:(UIImageView *)imageUserPicture{
    if([userId isEqualToString:myPicture.faceId]){
       [imageUserPicture setImage:myPicture];
    }else if([userId isEqualToString:bufferPic.faceId]){
       [imageUserPicture setImage:bufferPic];
    }else{
        NSString *profilePictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",userId];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:profilePictureUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       UIImage *image = [UIImage imageWithData:data];
                                       if(image) {
                                           [imageUserPicture setImage:image];
                                       }
                                   }
                               }];

    }
}

// Loads profile picture for the friends tab, called in the FacebooController or PeopleController (not sure about this last one ontroller)
-(void) loadPeopleProfilePicture:(NSString*)facebookId andImageCache:(NSMutableDictionary *)m_imageCache andUid:(int)uid andTableView: (UITableView*)tableView{
    NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture",facebookId] autorelease];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!error && data) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   if(image) {
                                       [m_imageCache setObject:image forKey:[NSNumber numberWithInt:uid]];
                                       [tableView reloadData];
                                   }
                               }
                           }];
}

// Function that cashes picture right at the sign up
-(void) cashProfilePicture{
    if(!myPicture){
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
       myPicture.faceId = appDelegate.myself.facebookId;
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=88&height=88",appDelegate.myself.facebookId] autorelease];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       myPicture = [[UIDyfocusImage alloc] initWithData:data];
                                   }
                               }];
    }
}

//Loads any profile picture based on facebookId
- (UIImage *) loadAnyProfilePicture:(UIImageView *)profileImageView andFacebookId:(NSString *)facebookId{
    if([bufferPic.faceId isEqualToString:facebookId]){
        [profileImageView setImage:bufferPic];
    }else{
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%i&height=%i",facebookId, (int)profileImageView.frame.size.width, (int)profileImageView.frame.size.height] autorelease];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       
                                       //if (bufferPic) {
                                       //    [bufferPic release];
                                       //    bufferPic = nil;
                                       //}
                                       
                                       bufferPic = [[[UIDyfocusImage alloc] initWithData:data] autorelease];
                                       bufferPic.faceId = facebookId;
                                       [profileImageView setImage:bufferPic];
                                   }
                               }];
    }
    return bufferPic;
}

//Loads my profile picture
- (UIImage *) loadMyProfilePicture:(UIImageView *)profileImageView{
    if(!myPicture){
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%i&height=%i",appDelegate.myself.facebookId, (int)profileImageView.frame.size.width, (int)profileImageView.frame.size.height] autorelease];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       myPicture = [[UIDyfocusImage alloc] initWithData:data];
                                       myPicture.faceId = appDelegate.myself.facebookId;
                                       [profileImageView setImage:myPicture];
                                   }
                               }];
    }else{
        [profileImageView setImage:myPicture];
    }
    return myPicture;
}

// Load profile picture for FOFTableList
- (void) loadListProfilePicture:(NSString *)facebookId andFOFId:(NSString *)fofId andImageView:(UIImageView*)imageUserPicture{
    if([facebookId isEqualToString:myPicture.faceId]){
        [imageUserPicture setImage:myPicture];
        imageUserPicture.tag = 420;
    }else if([facebookId isEqualToString:bufferPic.faceId]){
        [imageUserPicture setImage:bufferPic];
        imageUserPicture.tag = 420;
    }else{
        NSDyfocusURLRequest *request = [NSDyfocusURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",facebookId]]];
        request.id = fofId;
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       
                                       UIImage *image = [UIImage imageWithData:data];
                                       
                                       if(image && request.id == fofId) {
                                           [imageUserPicture setImage:image];
                                           imageUserPicture.tag = 420;
                                           image = nil;
                                       }
                                   }
                               }];
    }
}

// Calls profile of that user
- (void)loadUserProfileController:(NSString *)facebookId andUserName:(NSString *)userName andNavigationController:(UINavigationController *)navController{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    if(!appDelegate.insideUserProfile || ![facebookId isEqualToString:appDelegate.currentFriend.facebookId]){
        // needs userId, userName, NavigationController
        NSMutableArray *selectedPersonFofs = [NSMutableArray array];
        Person *person = [appDelegate.dyFriendsFromFace objectForKey:[NSNumber numberWithLong:[facebookId longLongValue]]];
        
        //WHEN THE COMMENT BELONGS TO A FRIEND:
        if(person){
            appDelegate.currentFriend = person;
            
            for (FOF *m_fof in appDelegate.feedFofArray) {
                
                if ([m_fof.m_userId isEqualToString: [NSString stringWithFormat: @"%@", person.facebookId]]) {
                    
                    [selectedPersonFofs addObject:m_fof];
                }
            }
            
            appDelegate.friendFofArray = selectedPersonFofs;
            
            FriendProfileController *friendProfileController = [[[FriendProfileController alloc] init] autorelease];
            friendProfileController.hidesBottomBarWhenPushed = YES;
            
            [friendProfileController clearCurrentUser];
            
            [navController pushViewController:friendProfileController animated:true];
            [navController setNavigationBarHidden:NO animated:TRUE];
            // WHEN THE COMMENT BELLONGS TO THE USER HIMSELF:
    //    }else if ([facebookId isEqualToString:appDelegate.myself.facebookId]){
    //        appDelegate.currentFriend = appDelegate.myself;
    //        appDelegate.profileController.hidesBottomBarWhenPushed = YES;
    //        [navController pushViewController:appDelegate.profileController animated:true];
    //        [navController setNavigationBarHidden:NO animated:TRUE];
    //        [appDelegate.tabBarController setSelectedIndex:4];
    //     WHEN THE COMMENT BELONGS TO A USER OTHER THAN MYSELF OR A FRIEND OF MINE:
        } else{
            if([facebookId isEqualToString:appDelegate.myself.facebookId]){
                appDelegate.currentFriend = appDelegate.myself;
            }else{
                appDelegate.currentFriend = [[Person alloc] initWithId:[facebookId longLongValue] andName:userName andUserName:@"" andfacebookId:facebookId];
            }
            FriendProfileController *friendProfileController = [[[FriendProfileController alloc] init] autorelease];
            friendProfileController.hidesBottomBarWhenPushed = YES;
            friendProfileController.userFacebookId = [facebookId copy];
            friendProfileController.userName = [userName copy];
            
            [navController pushViewController:friendProfileController animated:true];
            [navController setNavigationBarHidden:NO animated:TRUE];
        }
    }
}

@end
