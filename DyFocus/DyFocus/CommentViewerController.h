//
//  CommentViewerController.h
//  DyFocus
//
//  Created by Victor on 1/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SharingController.h"

@class TouchView;

@interface CommentViewerController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    IBOutlet UISearchBar *inputMessageTextField;
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *likesLabel;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *commentView;
    IBOutlet UITextView *fbCommentTextView;
    
    NSMutableArray *comments;
    NSMutableArray *likes;
    NSMutableString *likeListUsers;
    
    BOOL isKeyboardHidden;
    BOOL isTableEmpty;
    
    FOF *fof;
    
    int keyboardSize;
    
    BOOL isCommenting;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil andFOF:(FOF *)FOF;

- (void)hideKeyboard;

@property (nonatomic, retain) IBOutlet UISearchBar *inputMessageTextField;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *likesLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *commentView;
@property (nonatomic, retain) IBOutlet UITextView *fbCommentTextView;
@property (nonatomic) BOOL isKeyboardHidden;
@property (nonatomic,readwrite) BOOL isCommenting;
@end
