//
//  UIHorizontalTableViewCell.h
//  DyFocus
//
//  Created by Victor on 3/30/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIHorizontalTableViewCell : UITableViewCell {
    
    IBOutlet UIImageView *filterImage;
    IBOutlet UILabel *filterTitle;
}

@property (nonatomic,retain) IBOutlet UIImageView *filterImage;
@property (nonatomic,retain) IBOutlet UILabel *filterTitle;

-(void) refreshWithImage:(NSString *)imageName andTitle:(NSString *)title;

@end
