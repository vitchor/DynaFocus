//
//  PageControlFOFViewController.m
//  DyFocus
//
//  Created by Victor on 4/28/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "PageControlFOFViewController.h"

static NSArray *__pageControlColorList = nil;

@implementation PageControlFOFViewController

@synthesize pageNumberLabel, firstImageView, secondImageView, timer, frames, messageLabel;

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page {
    
    if (self = [super initWithNibName:@"PageControlFOFViewController" bundle:nil]) {
        pageNumber = page;
    }
    return self;
}

- (void)dealloc {
    [pageNumberLabel release];
    [super dealloc];
}

// Set the label and background color when the view has finished loading.
- (void)viewDidLoad {
    pageNumberLabel.text = [NSString stringWithFormat:@"Page %d", pageNumber + 1];
    //self.view.backgroundColor = [PageControlFOFViewController pageControlColorWithIndex:pageNumber];
    
    if (pageNumber == 0) {
        [messageLabel setText:@"Capture a scene with different focus points..."];
    } else if (pageNumber == 1) {
        [messageLabel setText:@"Try out capturing different exposure points as well..."];
    } else {
        [messageLabel setText:@"Add multiple animated filters and have fun!"];
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
    
}

- (void)fadeImages
{
    if ([frames count] > 0) {
        if (self.firstImageView.alpha >= 1.0) {
            
            if (timerPause > 0) {
                timerPause -= 1;
                
            } else {
                
                timerPause = TIMER_PAUSE;
                
                if (oldFrameIndex >= [self.frames count] - 1) {
                    oldFrameIndex = 0;
                } else {
                    oldFrameIndex += 1;
                }
                
                
                [self.secondImageView setImage:[self.frames objectAtIndex:oldFrameIndex]];
                
                [self.secondImageView setNeedsDisplay];
                
                [self.firstImageView setAlpha:0.0];
                
                [self.firstImageView setNeedsDisplay];
                
                int newIndex;
                if (oldFrameIndex == [self.frames count] - 1) {
                    newIndex = 0;
                } else {
                    newIndex = oldFrameIndex + 1;
                }
                
                [self.firstImageView setImage: [self.frames objectAtIndex: newIndex]];
                
            }
            
        } else {
            [self.firstImageView setAlpha:self.firstImageView.alpha + 0.01];
        }
    }
}


@end
