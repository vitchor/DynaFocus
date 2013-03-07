#import "AppDelegate.h"
#import "InvitationController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PeopleController.h"

@implementation InvitationController

@synthesize selectedPeople, infoView;

- (id)initWithDelegate:(id)delegate {
    if (self = [super init]) {
		self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		self.navigationItem.hidesBackButton = YES;
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)] autorelease];
		self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
		self.title = @"Edit Message";
		
		UILabel *description = [[[UILabel alloc] initWithFrame:CGRectMake(10, 12, 300, 20)] autorelease];
		description.font = [UIFont boldSystemFontOfSize:15.0];
		description.textColor = [UIColor blackColor];
		description.shadowColor = [UIColor whiteColor];
		description.textAlignment = UITextAlignmentCenter;
		description.numberOfLines = 2;
		description.shadowOffset = CGSizeMake(0,1);
		description.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
		description.text = [delegate description];
		[self.view addSubview:description];
        
        UILabel *descriptionDetail = [[[UILabel alloc] initWithFrame:CGRectMake(10, 37, 300, 40)] autorelease];
		descriptionDetail.font = [UIFont systemFontOfSize:14.0];
		descriptionDetail.textColor = [UIColor blackColor];
		descriptionDetail.shadowColor = [UIColor whiteColor];
		descriptionDetail.textAlignment = UITextAlignmentCenter;
		descriptionDetail.numberOfLines = 2;
		descriptionDetail.shadowOffset = CGSizeMake(0,1);
		descriptionDetail.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
		descriptionDetail.text = @"*Select an email that's registered to your facebook account.";
        descriptionDetail.numberOfLines=2;
		[self.view addSubview:descriptionDetail];
		
      
		m_delegate = [delegate retain];
		
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            m_messageView = [[UITextView alloc] initWithFrame:CGRectMake(20, 90, 280, 168)];
        } else {
            m_messageView = [[UITextView alloc] initWithFrame:CGRectMake(20, 90, 280, 80)];
        }
        
        m_messageView.backgroundColor = [UIColor whiteColor];
		m_messageView.delegate = self;
		m_messageView.enablesReturnKeyAutomatically = YES;
		m_messageView.font = [UIFont systemFontOfSize:16];
		m_messageView.layer.cornerRadius = 6.0;
		[m_messageView.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
		m_messageView.clipsToBounds = YES;
		m_messageView.text = [delegate hintText];
		[self.view addSubview:m_messageView];
          
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        
        [infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
        
        if (screenBounds.size.height == 568) {
            infoButton.frame = CGRectMake(275, 268, 30, 30);
        } else {
            infoButton.frame = CGRectMake(275, 180, 30, 30);
        }
        
		[self.view addSubview:infoButton];
        
        
	}
	return self;
}

- (void)showInfoView {
    [m_messageView endEditing:YES];

    if (!infoView) {
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            infoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)] autorelease];
        } else {
            infoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)] autorelease];
        }
        infoView.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    
        UILabel *titleView = nil;
        
        if (screenBounds.size.height == 568) {
            titleView = [[[UILabel alloc] initWithFrame: CGRectMake(10, 67, 300, 40)] autorelease];
        } else {
            titleView = [[[UILabel alloc] initWithFrame: CGRectMake(10, 45, 300, 40)] autorelease];
        }
        titleView.font = [UIFont boldSystemFontOfSize:21.0];
        titleView.textColor = [UIColor blackColor];
        titleView.shadowColor = [UIColor whiteColor];
        titleView.textAlignment = UITextAlignmentCenter;
        titleView.numberOfLines = 2;
        titleView.shadowOffset = CGSizeMake(0,1);
        titleView.text = @"Invitation Informations";
        titleView.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        
        UILabel *infoMessageLabel = nil;
        if (screenBounds.size.height == 568) {
            infoMessageLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10, 146, 300, 150)] autorelease];
        } else {
            infoMessageLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10, 102, 300, 150)] autorelease];
        }
        infoMessageLabel.font = [UIFont systemFontOfSize:19.0];
        infoMessageLabel.textColor = [UIColor blackColor];
        infoMessageLabel.shadowColor = [UIColor whiteColor];
        infoMessageLabel.textAlignment = UITextAlignmentCenter;
        infoMessageLabel.numberOfLines = 7;
        infoMessageLabel.shadowOffset = CGSizeMake(0,1);
        infoMessageLabel.text = @"The only way to send a facebook direct message from an app is throw your email account. Your friends will only receive this invite on their facebook message inbox.";
        infoMessageLabel.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        
        UILabel *infoMessageObservationLabel = nil;
        if (screenBounds.size.height == 568) {
            infoMessageObservationLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10, 346, 300, 100)] autorelease];
        } else {
            infoMessageObservationLabel = [[[UILabel alloc] initWithFrame: CGRectMake(10, 280, 300, 100)] autorelease];
        }
        infoMessageObservationLabel.font = [UIFont systemFontOfSize:19.0];
        infoMessageObservationLabel.textColor = [UIColor blackColor];
        infoMessageObservationLabel.shadowColor = [UIColor whiteColor];
        infoMessageObservationLabel.textAlignment = UITextAlignmentCenter;
        infoMessageObservationLabel.numberOfLines = 5;
        infoMessageObservationLabel.shadowOffset = CGSizeMake(0,1);
        infoMessageObservationLabel.text = @"*You need to select a sender email that's registered on your facebook account so your invites don't get tagged as spam.";
        infoMessageObservationLabel.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom] ; 
        
        if (screenBounds.size.height == 568) {
            backButton.frame = CGRectMake(10, 528, 80, 50);
        } else {
            backButton.frame = CGRectMake(10, 418, 80, 50);
        }
        
        [backButton setTitle:@"< Back" forState:UIControlStateNormal];
        
        [backButton setTitleColor: [UIColor colorWithRed:23.0f/255.0f green:68.0f/255.0f blue:117.0f/255.0f alpha:1.0] forState: UIControlStateNormal];
        
        [backButton setTitleColor: [UIColor blackColor] forState: UIControlStateSelected];
        
        
        //backButton[backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        //backButton.backgroundColor = [UIColor blackColor];*/
        
        [backButton addTarget:self action:@selector(hideInfoView) forControlEvents:UIControlEventTouchUpInside];
        
        [infoView addSubview:infoMessageLabel];
        [infoView addSubview:titleView];
        [infoView addSubview:infoMessageObservationLabel];
        [infoView addSubview:backButton];
    
    } else {
        [infoView setHidden:NO];
    }
    
    
    [self.navigationController.view addSubview:infoView];
    
}


-(void) hideInfoView {
    [infoView setHidden:YES];
    [m_messageView becomeFirstResponder];
}



- (void)dealloc {
	//RELEASE_MEMBER(m_messageView);
	[m_delegate release];
    [selectedPeople release];
    [super dealloc];
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[m_messageView becomeFirstResponder];
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
        NSString *message = [[[NSString alloc] initWithFormat:@"%@ <br/> https://itunes.apple.com/us/app/dyfocus/id557266156", m_messageView.text] autorelease];
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
	[self.navigationController dismissModalViewControllerAnimated:YES];
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
