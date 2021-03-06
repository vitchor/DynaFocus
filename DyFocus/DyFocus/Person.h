//
//  Person.h
//  DyFocus
//
//  Created by mhss on 3/18/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#define NOT_FRIEND 0
#define MYSELF 1                 // kind = 0: friend on both, App and  on  facebook
#define FRIENDS_ON_APP_AND_FB 2  // kind = 1: friend on both, App and  on  facebook
#define FRIENDS_ON_FB 3          // kind = 2: not a friend on App, just on facebook
#define FRIENDS_ON_APP 4         // kind = 3: friend just on App, NOT on facebook but a facebook user

@interface Person: NSObject {
    long m_uid;
    int m_kind;
	NSString *m_name;
	NSString *m_facebookUserName; // facebookUserName
	NSString *m_email;
    NSString *m_facebookId;
	BOOL m_selected;
    NSString *m_followersCount;
    NSString *m_followingCount;
    NSString *m_idOrigin;
}

@property(nonatomic, readwrite) long uid;
@property(nonatomic, readwrite) int kind;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *facebookUserName;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *facebookId;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, retain) NSString *followersCount;
@property(nonatomic, retain) NSString *followingCount;
@property(nonatomic, retain) NSString *idOrigin;

- (id)initWithDyfocusDic:(NSMutableDictionary*) facebookUser;
    
- (id) initWithId:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId;
- (id)initWithIdAndKind:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId andKind:(int)iKind;
- (id)initWithIdAndCounters:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId andKind:(int)iKind andIdOrigin:(NSString *)iIdOrigin andFollowersCount:(NSString *)iFollowersCount andFollowingCount:(NSString *)iFollowingCount;
- (id)initWithDic:(NSMutableDictionary*) facebookUser;
- (id)initWithDicAndKind:(NSMutableDictionary*) facebookUser andKind:(int)kind;

@end