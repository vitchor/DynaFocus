//
//  Like.m
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "Like.h"

@implementation Like

@synthesize m_userName, m_userId, m_fofId;

- (void)dealloc {
    [m_userName release];
    [m_fofId release];
    [m_userId release];
	[super dealloc];
}

@end

