//
//  UIHorizontalTableViewCell.m
//  DyFocus
//
//  Created by Victor on 3/30/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "UIHorizontalTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIHorizontalTableViewCell

@synthesize filterImage, filterTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
       
    }
    return self;
}

-(void) refreshWithImage:(NSString *)imageName andTitle:(NSString *)title {
    
    [filterImage setImage:[UIImage imageNamed:imageName]];
    
    filterImage.layer.cornerRadius = 9.0;
    [filterImage.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
    filterImage.clipsToBounds = YES;
    filterImage.layer.masksToBounds = YES;
    [filterTitle setText:title];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    assert([aDecoder isKindOfClass:[NSCoder class]]);
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        CGFloat k90DegreesClockwiseAngle = (CGFloat) (90 * M_PI / 180.0);
        
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k90DegreesClockwiseAngle);
    }
    
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    backView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    self.backgroundView = backView;
    
    assert(self);
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
