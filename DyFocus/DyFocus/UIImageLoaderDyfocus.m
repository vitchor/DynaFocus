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

+(id)sharedUIImageLoader{
    static UIImageLoaderDyfocus *sharedMyUILoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyUILoader = [[self alloc] init];
    });
    return sharedMyUILoader;
}

- (id)init {
    if (self = [super init]) {
//        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
    }
    return self;
}

- (void)dealloc {
    [myPicture dealloc];
    [bufferPic dealloc];
    [super dealloc];
    // Should never be called, but just here for clarity really.
}

- (void) loadProfilePicture:(NSString *)facebookId andProfileImage:(UIImageView *)profileImage{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([facebookId isEqualToString:[appDelegate.myself objectForKey:@"id"]]){
        [self loadMyProfilePicture:profileImage];
    }else{
        [self loadAnyProfilePicture:profileImage andFacebookId:facebookId];
    }
}

-(void) loadCommentProfilePicture:(NSString *)userId andImageView:(UIImageView *)imageUserPicture{
    if([userId isEqualToString:myPicture.tag]){
       [imageUserPicture setImage:myPicture];
    }else if([userId isEqualToString:bufferPic.tag]){
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

-(void) cashProfilePicture{
    if(!myPicture){
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=88&height=88",[appDelegate.myself objectForKey:@"id"]] autorelease];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       myPicture = [[UIDyfocusImage alloc] initWithData:data];
                                       myPicture.tag = [appDelegate.myself objectForKey:@"id"];
                                   }
                               }];
    }
}

- (UIImage *) loadAnyProfilePicture:(UIImageView *)profileImageView andFacebookId:(NSString *)facebookId{
    if([bufferPic.tag isEqualToString:facebookId]){
        [profileImageView setImage:bufferPic];
    }else{
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%i&height=%i",facebookId, (int)profileImageView.frame.size.width, (int)profileImageView.frame.size.height] autorelease];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       [bufferPic dealloc];
                                       bufferPic = nil;
                                       bufferPic = [[UIDyfocusImage alloc] initWithData:data];
                                       bufferPic.tag = facebookId;
                                       [profileImageView setImage:bufferPic];
                                   }
                               }];
    }
    return bufferPic;
}

- (UIImage *) loadMyProfilePicture:(UIImageView *)profileImageView{
    if(!myPicture){
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%i&height=%i",[appDelegate.myself objectForKey:@"id"], (int)profileImageView.frame.size.width, (int)profileImageView.frame.size.height] autorelease];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       myPicture = [[UIDyfocusImage alloc] initWithData:data];
                                       myPicture.tag = [appDelegate.myself objectForKey:@"id"];
                                       [profileImageView setImage:myPicture];
                                   }
                               }];
    }else{
        [profileImageView setImage:myPicture];
    }
    return myPicture;
}

- (void) loadListProfilePicture:(NSString *)facebookId andFOFId:(NSString *)fofId andImageView:(UIImageView*)imageUserPicture{
    if([facebookId isEqualToString:myPicture.tag]){
        [imageUserPicture setImage:myPicture];
        imageUserPicture.tag = 420;
    }else if([facebookId isEqualToString:bufferPic.tag]){
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


- (void)loadUserProfile:(NSString *)facebookId andUserName:(NSString *)userName andNavigationController:(UINavigationController *)navController{
    // needs userId, userName, NavigationController
    NSMutableArray *selectedPersonFofs = [[NSMutableArray alloc] init];
    Person *person = [[Person alloc] init];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    person = [appDelegate.dyfocusFriends objectForKey:[NSNumber numberWithLong:[facebookId longLongValue]]];
    
    //WHEN THE COMMENT BELONGS TO A FRIEND:
    if(person){
        appDelegate.currentFriend = person;
        
        for (FOF *m_fof in appDelegate.feedFofArray) {
            
            if ([m_fof.m_userId isEqualToString: [[NSString alloc] initWithFormat: @"%@", person.tag]]) {
                
                [selectedPersonFofs addObject:m_fof];
            }
        }
        
        appDelegate.friendFofArray = selectedPersonFofs;
        
        FriendProfileController *friendProfileController = [[[FriendProfileController alloc] init] autorelease];
        friendProfileController.hidesBottomBarWhenPushed = YES;
        
        [friendProfileController clearCurrentUser];
        
        [navController pushViewController:friendProfileController animated:true];
        [navController setNavigationBarHidden:NO animated:TRUE];
        //    // WHEN THE COMMENT BELLONGS TO THE USER HIMSELF:
        //    }else if ([m_comment.m_userId isEqualToString:[delegate.myself objectForKey:@"id"]]){
        //        [delegate.tabBarController setSelectedIndex:4];
        //        [commentController.navigationController release];
        // WHEN THE COMMENT BELONGS TO A USER OTHER THAN MYSELF OR A FRIEND OF MINE:
    } else{
        FriendProfileController *friendProfileController = [[[FriendProfileController alloc] init] autorelease];
        friendProfileController.hidesBottomBarWhenPushed = YES;
        friendProfileController.userFacebookId = facebookId;
        friendProfileController.userName = userName;
        
        [navController pushViewController:friendProfileController animated:true];
        [navController setNavigationBarHidden:NO animated:TRUE];
    }
}

@end
