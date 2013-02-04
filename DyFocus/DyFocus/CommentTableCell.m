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
#import "AppDelegate.h"

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
    
    NSString *profilePictureUrl = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture",comment.m_userId];
    
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
    m_comment = comment;
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
        [self showFriendProfile];
    }
}

- (void) showFriendProfile{
    NSMutableArray *selectedPersonFofs = [[NSMutableArray alloc] init];
    Person *person = [[Person alloc] init];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    person = [delegate.dyfocusFriends objectForKey:[NSNumber numberWithLong:[m_comment.m_userId longLongValue]]];

    if(person){
        delegate.currentFriend = person;

        for (FOF *fof in delegate.feedFofArray) {

            if ([fof.m_userId isEqualToString: [[NSString alloc] initWithFormat: @"%@", person.tag]]) {

                [selectedPersonFofs addObject:fof];
            }
        }

        delegate.friendFofArray = selectedPersonFofs;

        FriendProfileController *friendProfileController = [[[FriendProfileController alloc] init] autorelease];
        friendProfileController.hidesBottomBarWhenPushed = YES;

        [self.commentController.navigationController pushViewController:friendProfileController animated:true];
        [self.commentController.navigationController setNavigationBarHidden:NO animated:TRUE];
    }else if ([m_comment.m_userId isEqualToString:[delegate.myself objectForKey:@"id"]]){
        [delegate.tabBarController setSelectedIndex:4];
        [commentController.navigationController release];
    } else{
        [delegate showAlertBaloon:@"Not a friend" andAlertMsg:@"Sorry, this person is not your friend on Facebook." andAlertButton:@"OK" andController:commentController];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}    


@end
