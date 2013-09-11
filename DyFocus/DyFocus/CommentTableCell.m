//
//  FOFTableCell.m
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "CommentTableCell.h"

@implementation CommentTableCell

@synthesize imageUserPicture, deleteCommentBtn, labelUserName, commentTextView,  labelDate,  m_comment, commentController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
    }
    return self;
}

- (void) clear {
    
    if (self.m_comment) {
        [self.m_comment release];
        self.m_comment = nil;
    }
    
    [self.imageUserPicture setImage: [UIImage imageNamed:@"AvatarDefault.png"]];
    
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if(!self.commentController.isKeyboardHidden){
        //hides it
        [self.commentController hideKeyboard];
        self.commentController.isKeyboardHidden = YES;
    }else{
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        ProfileController *profileController = nil;
        Person *person;
        if(self.m_comment.m_userId == delegate.myself.uid){
            person = delegate.myself;
        }else{
            person = [delegate getUserWithId:self.m_comment.m_userId];
        }
        
        if (person) {
            profileController = [[ProfileController alloc] initWithPerson:person personFOFArray:[delegate FOFsFromUser:person.uid]];
        } else {
            profileController = [[ProfileController alloc] initWithUserId:self.m_comment.m_userId];
        }
        
        profileController.hidesBottomBarWhenPushed = YES;
        
        [self.commentController.navigationController pushViewController:profileController animated:YES];
        [self.commentController.navigationController setNavigationBarHidden:NO animated:TRUE];
        [profileController release];
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
    if(self.m_comment.m_uid){
        [LoadView loadViewOnView:self.commentController.view withText:@"Deleting..."];

        NSString *imageUrl = [[[NSString alloc] initWithFormat:@"%@/uploader/delete_comment/",dyfocus_url] autorelease];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        
        NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
        
        [jsonRequestObject setObject:self.m_comment.m_uid forKey:@"comment_id"];
        
        NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                               json] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(!error && data) {
                                       // Lets REFRESH COMMENT TABLE:
                                       for (Comment *comment in self.commentController.comments) {
                                           if([comment.m_uid longLongValue] == [self.m_comment.m_uid longLongValue]){
                                              [self.commentController.comments removeObject:comment];
                                               [comment release];
                                               break;
                                           }
                                       }
                                       [self.commentController.tableView reloadData];
                                       // TODO- Now it is time to decrease FofTableCell field                                       
                                       for (FOF *m_fof in self.commentController.tableCell.tableController.FOFArray) {
                                           if([m_fof.m_id longLongValue] == [self.m_comment.m_fofId longLongValue]){
                                               m_fof.m_comments = [NSString stringWithFormat:@"%d", [m_fof.m_comments intValue] - 1];
                                               [self.commentController.tableCell decreaseCommentsCounter];
                                           }
                                       }

                                       [LoadView fadeAndRemoveFromView:self.commentController.view];
                                   }
                               }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}    

- (void) refreshWithComment: (Comment *)comment {
    
    self.labelUserName.text = comment.m_userName;
    self.commentTextView.text = comment.m_message;
    
    if (comment.m_date && ![comment.m_date isEqualToString:@"null"]) {
        self.labelDate.text = comment.m_date;
    }
    
    
    UIImageLoaderDyfocus *imageLoader = [UIImageLoaderDyfocus sharedUIImageLoader];
    [imageLoader loadPictureWithFaceId:comment.m_userFacebookId andImageView:self.imageUserPicture andIsSmall:YES];
    
    if (self.m_comment) {
        [self.m_comment release];
        self.m_comment = nil;
    }
    
    self.m_comment = [[Comment alloc] init];
    self.m_comment.m_uid = [[comment.m_uid copy] autorelease];
    self.m_comment.m_date = [[comment.m_date copy] autorelease];
    self.m_comment.m_fofId = [[comment.m_fofId copy] autorelease];
    self.m_comment.m_message = [[comment.m_message copy] autorelease];
    self.m_comment.m_userFacebookId = [[comment.m_userFacebookId copy] autorelease];
    self.m_comment.m_userName = [[comment.m_userName copy] autorelease];
    self.m_comment.m_userId = comment.m_userId;
    
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)] autorelease];
    [self addGestureRecognizer:singleTap];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if(delegate.adminRule  ||  self.m_comment.m_userId == delegate.myself.uid){
        self.deleteCommentBtn.hidden = NO;
        UITapGestureRecognizer *singleTapDelete = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCommentPressed)] autorelease];
        [self.deleteCommentBtn addGestureRecognizer:singleTapDelete];
    }else{
        self.deleteCommentBtn.hidden = YES;
    }
}

-(void)dealloc
{
    [imageUserPicture release];
    [deleteCommentBtn release];
    [labelUserName release];
    [commentTextView release];
    [labelDate release];
    
    [m_comment release];
    [commentController release];
    
    [super dealloc];
}

@end
