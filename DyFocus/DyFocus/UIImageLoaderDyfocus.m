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

// Constructor
- (id)init {
    if (self = [super init]) {
//        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
        myPicture.faceId = 0;
    }
    return self;
}

- (void)dealloc {
    [myPicture dealloc];
    [super dealloc];
    // Should never be called, but just here for clarity really.
}

// Function that cashes picture right at the sign up
-(void) cashProfilePicture{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [self loadPictureWithFaceId:appDelegate.myself.facebookId andImageView:nil andIsSmall:NO];
}

//Loads Profile Picture, usually called from ProfileController or FriendProfileController
- (void) loadPictureWithFaceId:(NSString *)facebookId andImageView:(UIImageView *)profileImage andIsSmall:(BOOL)isSmall{
    
    if (!(facebookId == (id)[NSNull null] || facebookId.length == 0)) {
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        // cashProfilePicture: Cashes profile image in the login
        if(profileImage == nil){
            [self requestFacePicWithId:facebookId andSmall:NO andSize:0 andImageView:nil];
        }
        
        // loadMyPicture: Checks if the user is myself aaaaand checks if myPic is already loaded
        else if([facebookId isEqualToString:appDelegate.myself.facebookId]){
            if((!myPicture  ||  !myPicture.faceId)  ||  ![myPicture.faceId isEqualToString:appDelegate.myself.facebookId]) {
                [self requestFacePicWithId:facebookId andSmall:NO andSize:(int)profileImage.frame.size.height andImageView:profileImage];
            }else{
                [profileImage setImage:myPicture];
            }
            
        // loadUserPicture
        }else{           
            [self requestFacePicWithId:facebookId andSmall:isSmall andSize:profileImage.frame.size.height andImageView:profileImage];
        }
    }
}

//Private method:
-(void)requestFacePicWithId:(NSString*)faceId andSmall:(BOOL)isSmall andSize:(int)size andImageView:(UIImageView*)imageView {
    
    if (!(faceId == (id)[NSNull null] || faceId.length == 0)) {
         
        // Defines URL according to size
        NSString *imageUrl;
        if(isSmall){
            imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",faceId];
        }else{
            if(size!=0){
                imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=%d&height=%d",faceId, size, size] autorelease];

            }else{
                imageUrl = [[[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large&redirect=true&width=88&height=88",faceId] autorelease];
            }
        }
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
    //    if(fofId != nil){
    //        request.id = fofId;
    //    }
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       if([faceId isEqualToString:delegate.myself.facebookId]){
                                           myPicture = [[UIDyfocusImage alloc] initWithData:data];
                                           myPicture.faceId = faceId;
                                           if(imageView != nil){
                                               [imageView setImage:myPicture];
                                               imageView.tag = 420;
                                           }
                                       }else{
                                           
                                           
                                           UIImage *image = [UIImage imageWithData:data];

                                           if(imageView != nil){
                                               [imageView setImage:image];
                                               imageView.tag = 420;
                                           }
                                       }
                                   }
                               }];
    }
}




//I COULDN'T MODULARIZE THE FOLLOWING 2 CLASSES:
// Function used Just in the PeopleController
// Loads profile picture for the friends tab, called in the FacebooController or PeopleController (not sure about this last one ontroller)
-(void) loadFriendTabPicsWithFaceId:(NSString*)facebookId andImageCache:(NSMutableDictionary *)m_imageCache andUid:(int)uid andTableView: (UITableView*)tableView{
    
    if (!(facebookId == (id)[NSNull null] || facebookId.length == 0)) {
        
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
}


// Load profile picture for FOFTableList
- (void) loadFofTableCellUserPicture:(NSString *)facebookId andFOFId:(NSString *)fofId andImageView:(UIImageView*)imageUserPicture{
   if (!(facebookId == (id)[NSNull null] || facebookId.length == 0)) {
       
        if([facebookId isEqualToString:myPicture.faceId]){
            [imageUserPicture setImage:myPicture];
            imageUserPicture.tag = 420;
        } else{
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
}

@end
