//
//  InvitationController.m
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 3/13/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "AppDelegate.h"
#import "InvitationController.h"
#import "PeopleController.h"

@interface InvitationController ()

@end

@implementation InvitationController


@synthesize selectedPeople,messageTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		self.navigationItem.hidesBackButton = YES;
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)] autorelease];
		self.title = @"Edit Message";

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    messageTextView.layer.cornerRadius = 6.0;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[messageTextView becomeFirstResponder];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"InvitationController.viewDidAppear"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [infoView release];
    [messageTextView release];
    [selectedPeople release];
//    [_messageTextView release];
    [super dealloc];
}

- (IBAction)infoButtonTouch:(UIButton *)sender {
    [self showInfoView];
}

- (void)showInfoView {
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
    
    [infoView setHidden:NO];
    [messageTextView resignFirstResponder];
//    [messageTextView setEditable:NO];

}


-(void) hideInfoView {
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
    
    [infoView setHidden:YES];
    [messageTextView becomeFirstResponder];
//    [messageTextView setEditable:YES];
}

- (void)saveAction {
	//[m_delegate saveInviteWithText:[m_messageView text]];
	//[self.navigationController dismissModalViewControllerAnimated:YES];
    
    NSMutableArray *emailReceivers = [[[NSMutableArray alloc] init] autorelease];
    
    for (Person *person in selectedPeople) {
        
        NSString *email = [[[NSString alloc] initWithFormat:@"%@@facebook.com", person.details] autorelease];
        [emailReceivers addObject:email];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"dyfocus Invitation"];
        NSString *message = [[[NSString alloc] initWithFormat:@"%@ <br/> https://itunes.apple.com/us/app/dyfocus/id557266156", messageTextView.text] autorelease];
        [controller setMessageBody:message isHTML:YES];
        [controller setToRecipients:emailReceivers];
        if (controller) [self presentModalViewController:controller animated:YES];
        [controller release];
        
    } else {
        [self showOkAlertWithMessage:@"Configure your device email app.\nGo to: \"Settings\" -> \"Mail, Contacts, Calendars\" -> Turn ON your Mail app." andTitle:@"Error"];
    }
    
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        [delegate invitationSentGoBackToFriends];
    }
    [self dismissModalViewControllerAnimated:YES];
}


- (void)cancelAction {
    
    if(infoView.isHidden){
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self hideInfoView];
    }
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertButton release];
}

@end
