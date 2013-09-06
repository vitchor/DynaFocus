//
//  FOFTableCell.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "JSON.h"

#import "LoadView.h"
#import "AppDelegate.h"
#import "UIImageLoaderDyfocus.h"

#import "FOFTableController.h"
#import "CommentViewerController.h"

@interface CommentTableCell : UITableViewCell {
    
}

@property (nonatomic,retain) IBOutlet UIImageView *imageUserPicture;
@property (nonatomic,retain) IBOutlet UIButton *deleteCommentBtn;
@property (nonatomic,retain) IBOutlet UILabel *labelUserName;
@property (nonatomic,retain) IBOutlet UILabel *commentTextView;
@property (nonatomic,retain) IBOutlet UILabel *labelDate;

@property (nonatomic,retain) Comment *m_comment;
@property (nonatomic,retain) CommentViewerController *commentController;

- (void) refreshWithComment: (Comment *)comment;

@end
