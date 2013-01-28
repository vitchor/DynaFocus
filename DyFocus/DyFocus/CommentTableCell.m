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
@synthesize labelUserName ,labelDate, imageUserPicture, commentTextView, whiteView;

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
    //labelDate.text = comment.m_date;
    
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
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}    


@end
