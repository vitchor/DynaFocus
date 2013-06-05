//
//  Comment.m
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize m_message, m_userId, m_userName, m_userFacebookId, m_fofId, m_date;

- (void)dealloc {
    [m_message release];
    [m_userName release];
    [m_fofId release];
    [m_userFacebookId release];
    [m_date release];
	[super dealloc];
}

@end
