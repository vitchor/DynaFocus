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
#import "LoadView.h"

@implementation CommentTableCell
@synthesize labelUserName ,labelDate, imageUserPicture, commentTextView, whiteView, commentController, m_comment, deleteCommentBtn;

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
    
    labelUserName.text = comment.m_userName;
    commentTextView.text = comment.m_message;

    if (comment.m_date && ![comment.m_date isEqualToString:@"null"]) {
        labelDate.text = comment.m_date;
    }
    
    
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
    [imageLoader loadPictureWithFaceId:comment.m_userFacebookId andImageView:imageUserPicture andIsSmall:YES];  
    
    if (m_comment) {
        [m_comment release];
        m_comment = nil;
    }
    
    m_comment = [[Comment alloc] init];
    m_comment.m_uid = [[comment.m_uid copy] autorelease];
    m_comment.m_date = [[comment.m_date copy] autorelease];
    m_comment.m_fofId = [[comment.m_fofId copy] autorelease];
    m_comment.m_message = [[comment.m_message copy] autorelease];
    m_comment.m_userFacebookId = [[comment.m_userFacebookId copy] autorelease];
    m_comment.m_userName = [[comment.m_userName copy] autorelease];
    m_comment.m_userId = comment.m_userId;
    
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)] autorelease];
    [self addGestureRecognizer:singleTap];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

    if(m_comment.m_userId == delegate.myself.uid){
        deleteCommentBtn.hidden = NO;
        UITapGestureRecognizer *singleTapDelete = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCommentPressed)] autorelease];
        [deleteCommentBtn addGestureRecognizer:singleTapDelete];
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
        Person *person;
        if(m_comment.m_userId == delegate.myself.uid){
            person = delegate.myself;
        }else{
            person = [delegate getUserWithId:m_comment.m_userId];
        }
        
        if (person) {
            profileController = [[ProfileController alloc] initWithPerson:person personFOFArray:[delegate FOFsFromUser:person.uid]];
        } else {
            profileController = [[ProfileController alloc] initWithUserId:m_comment.m_userId];
        }
        
        profileController.hidesBottomBarWhenPushed = YES;
        
        [commentController.navigationController pushViewController:profileController animated:YES];
        [commentController.navigationController setNavigationBarHidden:NO animated:TRUE];
    }
}


-(void)deleteCommentPressed {
    NSString *alertTitle = @"Delete this comment?";
    NSString *alertMsg =@"You'll erase this comment. Are you sure?";
    NSString *alertButton1 = @"Yes";
    NSString *alertButton2 =@"No";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton1 otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert setTag:1];
    [alert addButtonWithTitle:alertButton2];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton1 release];
    [alertButton2 release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 0) {
            [self eraseComment];
        }
    }
}

- (void) eraseComment {
    if(m_comment.m_uid){
        [LoadView loadViewOnView:commentController.view withText:@"Deleting..."];

        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/delete_comment/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
        
        [jsonRequestObject setObject:m_comment.m_uid forKey:@"comment_id"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       deleteCommentBtn.hidden = YES;
                                       // Lets REFRESH COMMENT TABLE:
                                       for (Comment *comment in commentController.comments) {
                                           if([comment.m_uid longLongValue] == [m_comment.m_uid longLongValue]){
                                              [commentController.comments removeObject:comment];
                                               [comment release];
                                               break;
                                           }
                                       }
                                       [commentController.tableView reloadData];
                                       // TODO- Now it is time to decrease FofTableCell field                                       
                                       for (FOF *m_fof in commentController.tableCell.tableView.FOFArray) {
                                           if([m_fof.m_id longLongValue] == [m_comment.m_fofId longLongValue]){
                                               m_fof.m_comments = [NSString stringWithFormat:@"%d", [m_fof.m_comments intValue] - 1];
                                               [commentController.tableCell decreaseCommentsCounter];
                                           }
                                       }

                                       [LoadView fadeAndRemoveFromView:commentController.view];
                                   }
                               }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}    


@end
