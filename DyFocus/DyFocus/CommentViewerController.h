//
//  CommentViewerController.h
//  DyFocus
//
//  Created by Victor on 1/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LikesTableViewController.h"

#import "JSON.h"
#import "LoadView.h"
#import "AppDelegate.h"
#import "FOFTableCell.h"

#define kOFFSET_FOR_KEYBOARD 400.0

@interface CommentViewerController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    int keyboardSize;
    BOOL isTableEmpty;
    
    IBOutlet UILabel *sharingLabel;
    IBOutlet UILabel *sharingCompletedLabel;
    IBOutlet UILabel *likesLabel;
    
    IBOutlet UIView *commentView;
    IBOutlet UIView *likesView;
    IBOutlet UIView *activityView;
    
    IBOutlet UITextView *fbCommentTextView;
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UISearchBar *inputMessageTextField;
    IBOutlet UIActivityIndicatorView *activityIndicator;

    NSMutableArray *likes;
    
    FOF *fof;
}

@property (nonatomic,readwrite) BOOL isKeyboardHidden;
@property (nonatomic,readwrite) BOOL isCommenting;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) FOFTableCell *tableCell;

- (id)initWithNibName:(NSString *)nibNameOrNil andFOF:(FOF *)FOF;
- (void)hideKeyboard;

@end
