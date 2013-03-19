//
//  Person.m
//  DyFocus
//
//  Created by mhss on 3/18/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize kind = m_kind, name = m_name, facebookUserName = m_facebookUserName, email = m_email, facebookId = m_facebookId, timezone = m_timezone, location = m_location, selected = m_selected;
// kind = 0: friend on both, App and  on  facebook
// kind = 1: not a friend on App, just on facebook
// kind = 2: friend just on App, NOT on facebook but a facebook user

-(id) initWithId:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId{
    self = [super init];
    if (self) {
        [self objectFromId:iUid andName:iName andUserName:iUserName andfacebookId:iFacebookId];
    }
    return self;
}

- (id)initWithIdAndKind:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId andKind:(int)iKind{
    self = [super init];
    if (self) {
        [self objectFromId:iUid andName:iName andUserName:iUserName andfacebookId:iFacebookId];
        m_kind = iKind;
    }
	return self;
}

// called from this class
-(void) objectFromId:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId{
    m_facebookId = [iFacebookId retain];
    m_name = [iName retain];
    m_facebookUserName = [iUserName retain];
    m_selected = NO;
    m_uid = iUid;
    m_email = @"";
    m_location = @"";
    m_timezone = 0;
}

- (id)initWithDic:(NSMutableDictionary*) facebookUser {
    self = [super init];
    if (self) {
        [self objectFromDictionary:facebookUser];
    }
    return self;
}

- (id)initWithDicAndKind:(NSMutableDictionary*) facebookUser andKind:(int)kind {
    self = [super init];
    if (self) {
        [self objectFromDictionary:facebookUser];
        m_kind= kind;
    }
    return self;
}

//called from this class
- (void)objectFromDictionary:(NSMutableDictionary*)facebookUser {
    m_facebookId = [[facebookUser objectForKey:@"id"] retain];
    m_name = [[facebookUser objectForKey:@"name"] retain];
    m_selected = NO;
    m_email = [[facebookUser objectForKey:@"email"] retain];
    m_facebookUserName = [[facebookUser objectForKey:@"username"] retain];
    @try {
        m_timezone = [[facebookUser objectForKey:@"timezone"] floatValue];
    }
    @catch (NSException *exception) {
        m_timezone = 0;
        NSLog(@"!!! EXCEPTION on timezone attribute: %@", exception);
    }
    
    @try {
        m_location = [[[facebookUser objectForKey:@"location"] objectForKey:@"name"] retain];
    }
    @catch (NSException *exception) {
        m_location = [[facebookUser objectForKey:@"location"] retain];
        NSLog(@"!!! EXCEPTION on location attribute: %@", exception);
    }
}

- (void)dealloc {
    [m_name release];
    [m_facebookUserName release];
    [m_facebookId release];
    [m_email release];
    [m_location release];
	[super dealloc];
}

@end

