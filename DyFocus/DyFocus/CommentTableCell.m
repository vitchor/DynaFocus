//
//  FOFTableCell.m
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "CommentTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"
#import "UIImageLoaderDyfocus.h"

@implementation CommentTableCell
@synthesize labelUserName ,labelDate, imageUserPicture, commentTextView, whiteView, commentController, m_comment;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
    }
    return self;
}

- (void) clear {
    
    if (m_comment) {
        [m_comment release];
        m_comment = nil;
    }
    
    [imageUserPicture setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    
}


- (void) refreshWithComment: (Comment *)comment {
    
    if (!m_comment || ([m_comment.m_message isEqualToString:comment.m_message] && [m_comment.m_userId isEqualToString:comment.m_userId])) {
        
        [self clear];
        
        labelUserName.text = comment.m_userName;
        commentTextView.text = comment.m_message;

        if (comment.m_date && ![comment.m_date isEqualToString:@"null"]) {
            labelDate.text = comment.m_date;
        }
        
        
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        [imageLoader loadPictureWithFaceId:comment.m_userId andImageView:imageUserPicture andIsSmall:YES];
//        [imageLoader loadCommentProfilePicture:comment.m_userId andImageView:imageUserPicture];    
        
        if (m_comment) {
            [m_comment release];
            m_comment = nil;
        }
        
        m_comment = [[Comment alloc] init];
        m_comment.m_date = [[comment.m_date copy] autorelease];
        m_comment.m_fofId = [[comment.m_fofId copy] autorelease];
        m_comment.m_message = [[comment.m_message copy] autorelease];
        m_comment.m_userId = [[comment.m_userId copy] autorelease];
        m_comment.m_userName = [[comment.m_userName copy] autorelease];
        
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)] autorelease];
        [self addGestureRecognizer:singleTap];
        
    }
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if(!commentController.isKeyboardHidden){
        //hides it
        [commentController hideKeyboard];
        commentController.isKeyboardHidden = YES;
    }else{
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        ProfileController *profileController = nil;
        Person *person = [delegate getUserWithFacebookId: [m_comment.m_userId longLongValue]];
        
        
        NSLog(@"FACEBOOK USER %lld", [m_comment.m_userId longLongValue]);
        
        if (person) {
            profileController = [[ProfileController alloc] initWithPerson:person personFOFArray:[delegate FOFsFromUser:person.facebookId]];
        } else {
            profileController = [[ProfileController alloc] initWithFacebookId:m_comment.m_userId];
        }
        
        [commentController.navigationController pushViewController:profileController animated:YES];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}    


@end
