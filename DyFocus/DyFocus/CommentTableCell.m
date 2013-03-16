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

- (void) refreshWithComment: (Comment *)comment {
    labelUserName.text = comment.m_userName;
    commentTextView.text = comment.m_message;

    if (comment.m_date && ![comment.m_date isEqualToString:@"null"]) {
        labelDate.text = comment.m_date;
    }
    
    
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
    [imageLoader loadCommentProfilePicture:comment.m_userId andImageView:imageUserPicture];    
    
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
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self addGestureRecognizer:singleTap];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if(!commentController.isKeyboardHidden){
        //hides it
        [commentController hideKeyboard];
        commentController.isKeyboardHidden = YES;
    }else{
        UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
        [imageLoader loadUserProfileController:m_comment.m_userId andUserName:m_comment.m_userName andNavigationController:commentController.navigationController];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}    


@end
