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

@synthesize cameraViewController, instructionsImagesEnumerator;
//, supportEmailLabel;

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
        
        UITapGestureRecognizer *singleTapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextInstruction)];
        [self addGestureRecognizer:singleTapOnView];
        [singleTapOnView release];
        
        UITapGestureRecognizer *singleTapOnLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendSupportEmail)];
        [supportEmailLabel addGestureRecognizer:singleTapOnLabel];
        [singleTapOnLabel release];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        if (screenBounds.size.height == 568) {
        
            UIImage *instruction1 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP01-i5" ofType:@"png"]];
            
            UIImage *instruction2 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP02-i5" ofType:@"png"]];
            
            UIImage *instruction3 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP03-i5" ofType:@"png"]];
            
            UIImage *instruction4 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP04-i5" ofType:@"png"]];
            
            UIImage *instruction5 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP05-i5" ofType:@"png"]];
            
            instructionsImagesArray = [[NSMutableArray alloc] initWithObjects:instruction1, instruction2, instruction3, instruction4, instruction5, nil];
        }else{
            
            UIImage *instruction1 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP01" ofType:@"png"]];
            
            UIImage *instruction2 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP02" ofType:@"png"]];
            
            UIImage *instruction3 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP03" ofType:@"png"]];
            
            UIImage *instruction4 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP04" ofType:@"png"]];
            
            UIImage *instruction5 = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DfShootInstructionsP05" ofType:@"png"]];
            
            instructionsImagesArray = [[NSMutableArray alloc] initWithObjects:instruction1, instruction2, instruction3, instruction4, instruction5, nil];
        }
        
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

-(void)nextInstruction
{    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.nextInstruction"];
    
    [self setImage:self.instructionsImagesEnumerator.nextObject];
    
    if(self.image == instructionsImagesArray.lastObject)
        [supportEmailLabel setHidden:NO];
    else
        [supportEmailLabel setHidden:YES];
    
    if(!self.image){
        [self setHidden:YES];
        [self.cameraViewController.shootButton setEnabled:YES];
    }
}

-(void)loadTutorial:(BOOL)shouldShowTutorial
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"TutorialView.showTutorial"];
    
   if(self.instructionsImagesEnumerator)
       self.instructionsImagesEnumerator = nil;
    
    self.instructionsImagesEnumerator = [instructionsImagesArray objectEnumerator];
    
    [self setImage:self.instructionsImagesEnumerator.nextObject];
    
    [self setHidden:!shouldShowTutorial];
    [self.cameraViewController.shootButton setEnabled:!shouldShowTutorial];
    
    [supportEmailLabel setHidden:YES];
}

- (void)sendSupportEmail {
    
    NSArray *supportEmail = [[[NSArray alloc] initWithObjects:@"support@dyfoc.us", nil] autorelease];
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController* mailComposeController = [[MFMailComposeViewController alloc] init];
        
        mailComposeController.mailComposeDelegate = self;
        [mailComposeController setSubject:@"User Feedback"];
        [mailComposeController setToRecipients:supportEmail];
        
        if (mailComposeController)
            [self.cameraViewController presentModalViewController:mailComposeController animated:YES];
        
        [mailComposeController release];
        
    } else {
        [self showOkAlertWithMessage:@"Configure your device email app.\nGo to: \"Settings\" -> \"Mail, Contacts, Calendars\" -> Turn ON your Mail app." andTitle:@"Error"];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent || result == MFMailComposeResultCancelled) {
        NSLog(@"It's away!");
    }
    else if(result == MFMailComposeResultSaved) {
       [self showOkAlertWithMessage:@"The draft was saved in your email box." andTitle:@"Draft Saved"];
    }
    else if(result == MFMailComposeResultFailed){
        
        [self showOkAlertWithMessage:@"There was an error sending your email. Please try again later." andTitle:@"Error"];
    }
    
    [self.cameraViewController dismissModalViewControllerAnimated:YES];
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}


-(void)dealloc
{
    [instructionsImagesArray release];
    [self.instructionsImagesEnumerator release];
    [cameraViewController release];
    [supportEmailLabel release];
    [super dealloc];
}


@end
