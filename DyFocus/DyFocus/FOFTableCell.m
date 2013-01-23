//
//  FOFTableCell.m
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOFTableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FOFTableCell
@synthesize labelUserName ,labelDate, buttonLike, buttonComment, imagefrontFrame, imagebackFrame, imageUserPicture, timer, spinner, whiteView, tableView, row, commentsCountLabel, likesCountLabel, buttonShare;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
    }
    return self;
}

- (void) refreshWithFof:(FOF *)fof {
    whiteView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    whiteView.layer.cornerRadius = 3.0f;
    whiteView.layer.borderWidth = 1.0f;

    [labelUserName setText:fof.m_userName];
    [labelDate setText:fof.m_date];
    if (fof.m_comments) {
        
        [commentsCountLabel setText:[[[NSString alloc] initWithFormat:@"%d", [fof.m_comments count]]autorelease]];
        
    } else {
        [commentsCountLabel setText:@"0"];
    }
    
    //[buttonLike setTitle: [[[NSString alloc] initWithFormat:@"Like (%@)", fof.m_likes]autorelease] forState:UIControlStateNormal];
    
    [likesCountLabel setText:[[[NSString alloc] initWithFormat:@"%@", fof.m_likes] autorelease]];
    
    
    profilePictureUrl = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture",fof.m_userId];
    
    fofUrls = [[NSMutableArray alloc] init];
    for (NSDictionary *frame in fof.m_frames) {
        
        NSLog([frame debugDescription]);
        [fofUrls addObject:[frame objectForKey:@"frame_url"]];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) startTimer {
    
    [spinner stopAnimating];
    [spinner setHidden:YES];
    
    [self.imagefrontFrame setImage: [frames objectAtIndex:0]];
    
    if ([frames count] > 1) {
        [self.imagebackFrame setImage: [frames objectAtIndex:1]];
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];

}

-(void)loadImages {
    
    if (!frames) {
        
        [spinner startAnimating];
        

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
        
        
        
        if (!frames) {
        
            frames = [[NSMutableArray alloc] init];
            downloadedFrames = 0;

            for (NSString *frameUrl in fofUrls) {
                
                 NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:frameUrl]];
                
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           if(!error && data) {
                                               UIImage *image = [UIImage imageWithData:data];
                                               if(image) {
                                                   [frames addObject:image];
                                                   
                                                   float scale = image.size.height / image.size.width;
                                                   
                                                   //NSLog(@"HEIGHT: %f", image.size.height);
                                                   //NSLog(@"WIDTH: %f", image.size.width);
                                                   //NSLog(@"SCALE: %f", scale);
                                                   if (scale > 1) {
                                                       
                                                       float newHeight = imagebackFrame.frame.size.width * scale;
                                                       
                                                       [self.tableView addNewCellHeight:newHeight atRow:self.row];
                                                       
                                                        imagebackFrame.frame = CGRectMake(imagebackFrame.frame.origin.x,
                                                                                           imagebackFrame.frame.origin.y , imagebackFrame.frame.size.width, newHeight);
                                                       
                                                      
                                                       //imagebackFrame.clipsToBounds = YES;
                                                       newHeight = imagefrontFrame.frame.size.width * scale;
                                                       imagefrontFrame.frame = CGRectMake(imagefrontFrame.frame.origin.x,
                                                                                            imagefrontFrame.frame.origin.y, imagefrontFrame.frame.size.width, newHeight);
                                                                                                              
                                                     
                                                   }
                                                   
                                                   //imagefrontFrame.clipsToBounds = YES;
                                               }
                                               
                                               if ([frames count] == [fofUrls count]) {
                                                   [self startTimer];
                                                   
                                                   
                                               }
                                           }
                                       }];
            }
        }
    }
}

- (void)fadeImages
{
    if (self.imagefrontFrame.alpha >= 1.0) {
        
        if (timerPause > 0) {
            timerPause -= 1;
            
        } else {
            
            timerPause = TIMER_PAUSE;
            
            if (oldFrameIndex >= [frames count] - 1) {
                oldFrameIndex = 0;
            } else {
                oldFrameIndex += 1;
            }
            
            
            [self.imagebackFrame setImage:[frames objectAtIndex:oldFrameIndex]];
            
            [self.imagebackFrame setNeedsDisplay];
            
            [self.imagefrontFrame setAlpha:0.0];
            
            [self.imagefrontFrame setNeedsDisplay];
            
            int newIndex;
            if (oldFrameIndex == [frames count] - 1) {
                newIndex = 0;
            } else {
                newIndex = oldFrameIndex + 1;
            }
            
            [self.imagefrontFrame setImage: [frames objectAtIndex: newIndex]];
            
        }
        
    } else {
        [self.imagefrontFrame setAlpha:self.imagefrontFrame.alpha + 0.01];
    }
    
}

@end