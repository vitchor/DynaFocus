//
//  InvitationController.m
//  UberClient
//
//  Created by Jordan Bonnet on 2/11/11.
//  Copyright 2011 Ubercab LLC. All rights reserved.
//

#import "InvitationController.h"
#import <QuartzCore/QuartzCore.h>

@implementation InvitationController

- (id)initWithDelegate:(id)delegate {
    if (self = [super init]) {
		self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		self.navigationItem.hidesBackButton = YES;
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)] autorelease];
		self.view.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
		self.title = @"Message";
		
		UILabel *description = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)] autorelease];
		description.font = [UIFont systemFontOfSize:14.0];
		description.textColor = [UIColor blackColor];
		description.shadowColor = [UIColor whiteColor];
		description.textAlignment = UITextAlignmentCenter;
		description.numberOfLines = 2;
		description.shadowOffset = CGSizeMake(0,1);
		description.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
		description.text = [delegate description];
		[self.view addSubview:description];
		
		m_delegate = [delegate retain];
		m_messageView = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, 280, 140)];
		m_messageView.backgroundColor = [UIColor whiteColor];
		m_messageView.delegate = self;
		m_messageView.enablesReturnKeyAutomatically = YES;
		m_messageView.font = [UIFont systemFontOfSize:16];
		m_messageView.layer.cornerRadius = 5.0;
		[m_messageView.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
		m_messageView.clipsToBounds = YES;
		m_messageView.text = [delegate hintText];
		[self.view addSubview:m_messageView];
	}
	return self;
}

- (void)dealloc {
	//RELEASE_MEMBER(m_messageView);
	[m_delegate release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[m_messageView becomeFirstResponder];
}

- (void)saveAction {
	[m_delegate saveInviteWithText:[m_messageView text]];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)cancelAction {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
