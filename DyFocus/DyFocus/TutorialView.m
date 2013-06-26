//
//  TutorialView.m
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 6/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "TutorialView.h"
#import "AppDelegate.h"

@implementation TutorialView

@synthesize instructionsImagesEnumerator, cameraViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        [self setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextInstruction)];
        [self addGestureRecognizer:singleTap];
        [singleTap release];
        
//        CGRect screenBounds = [[UIScreen mainScreen] bounds];
//        if (screenBounds.size.height == 568) {
//        
//        }
        
        UIImage *instruction1 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP01" ofType:@"png"]];
  
        UIImage *instruction2 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP02" ofType:@"png"]];
        
        UIImage *instruction3 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP03" ofType:@"png"]];
        
        UIImage *instruction4 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP04" ofType:@"png"]];
        
        instructionsImagesArray = [[NSMutableArray alloc] initWithObjects:instruction1, instruction2, instruction3, instruction4, nil];
        
        [self loadTutorial:NO];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate logEvent:@"TutorialView initialized"];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)nextInstruction{
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.nextInstruction"];
    
    [self setImage:self.instructionsImagesEnumerator.nextObject];
    
    if(!self.image){
        [self setHidden:YES];
        [self.cameraViewController.shootButton setEnabled:YES];
    }
}

-(void)loadTutorial:(BOOL)shouldShowTutorial
{
   if(self.instructionsImagesEnumerator)
       self.instructionsImagesEnumerator = nil;
    
    self.instructionsImagesEnumerator = [instructionsImagesArray objectEnumerator];
    
    [self setImage:self.instructionsImagesEnumerator.nextObject];
    
    [self setHidden:!shouldShowTutorial];
    [self.cameraViewController.shootButton setEnabled:!shouldShowTutorial];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.showTutorial"];
}

-(void)dealloc
{
    [instructionsImagesArray release];
    [instructionsImagesEnumerator release];
    [super dealloc];
}


@end
