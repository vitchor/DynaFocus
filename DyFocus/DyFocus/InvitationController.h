//
//  InvitationController.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 3/13/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InvitationController : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate>
{
    IBOutlet UIView *infoView;
    IBOutlet UITextView *messageTextView;

    NSMutableArray *selectedPeople;
}

@property(nonatomic, retain) NSMutableArray *selectedPeople;
@property (retain, nonatomic) IBOutlet UITextView *messageTextView;

- (IBAction)infoButtonTouch:(UIButton *)sender;

@end
