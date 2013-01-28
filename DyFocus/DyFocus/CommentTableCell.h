//
//  FOFTableCell.h
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FOFTableController.h"

@interface CommentTableCell : UITableViewCell {

    IBOutlet UILabel *labelUserName;
    IBOutlet UILabel *labelDate;
    
    IBOutlet UIImageView *imageUserPicture;
        
    IBOutlet UIView *whiteView;
        
    IBOutlet UILabel *commentTextView;
    
    int row;
    
}

- (void) loadImages;
- (void) refreshWithComment: (Comment *)comment;

@property (nonatomic,retain) IBOutlet UILabel *labelUserName;
@property (nonatomic,retain) IBOutlet UILabel *commentTextView;
@property (nonatomic,retain) IBOutlet UILabel *labelDate;

@property (nonatomic,retain) IBOutlet UIImageView *imageUserPicture;

@property (nonatomic,retain) IBOutlet UIView *whiteView;

@end
